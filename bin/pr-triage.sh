#!/usr/bin/env bash
set -uo pipefail

# pr-triage.sh — PR triage tool for glade-ai org
# Default: generates ~/dev/glade/pr-triage.md and opens in mdcat
# --json: outputs NDJSON to stdout
# --watch [N]: regenerates every N minutes (default 5)

MY_LOGIN="marneborn"
OWNER="glade-ai"
OUTPUT_FILE="$HOME/dev/glade/pr-triage.md"
FORMAT="markdown"
WATCH=false
WATCH_INTERVAL=5

while [ $# -gt 0 ]; do
    case "$1" in
        --json) FORMAT="json"; shift ;;
        --watch) WATCH=true; shift
            if [ $# -gt 0 ] && [[ "$1" =~ ^[0-9]+$ ]]; then
                WATCH_INTERVAL="$1"; shift
            fi ;;
        *) shift ;;
    esac
done

if ! gh auth status >/dev/null 2>&1; then
    echo '{"error":"gh CLI not authenticated — run gh auth login"}' >&2
    exit 1
fi

GRAPHQL_QUERY='query($q: String!, $cursor: String) {
  search(query: $q, type: ISSUE, first: 50, after: $cursor) {
    edges {
      node {
        ... on PullRequest {
          number
          title
          url
          headRefName
          author { login }
          reviewDecision
          mergeable
          isDraft
          state
          createdAt
          updatedAt
          additions
          deletions
          changedFiles
          mergeStateStatus
          reviews(last: 50) {
            nodes {
              author { login }
              state
              submittedAt
            }
          }
          latestReviews(last: 20) {
            nodes {
              author { login }
              state
              submittedAt
            }
          }
          reviewRequests(last: 20) {
            nodes {
              requestedReviewer {
                ... on User { login }
              }
            }
          }
          comments(last: 30) {
            nodes {
              author { login }
              createdAt
            }
          }
          commits(last: 1) {
            nodes {
              commit {
                committedDate
                oid
                statusCheckRollup {
                  contexts(first: 50) {
                    nodes {
                      ... on CheckRun { conclusion status }
                      ... on StatusContext { state }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    pageInfo { hasNextPage endCursor }
  }
}'

fetch_prs() {
    local search_query="$1"
    local pr_type="$2"
    local all_results="[]"
    local cursor=""
    local has_next="true"

    while [ "$has_next" = "true" ]; do
        local response
        if [ -z "$cursor" ]; then
            response=$(gh api graphql -f query="$GRAPHQL_QUERY" -f q="$search_query" 2>&1)
        else
            response=$(gh api graphql -f query="$GRAPHQL_QUERY" -f q="$search_query" -f cursor="$cursor" 2>&1)
        fi

        if echo "$response" | jq -e '.errors' >/dev/null 2>&1; then
            local err_msg
            err_msg=$(echo "$response" | jq -r '.errors[0].message // "unknown error"')
            echo "{\"error\":\"GitHub GraphQL error: $err_msg\"}" >&2
            exit 1
        fi

        local page
        page=$(echo "$response" | jq -c --arg t "$pr_type" '[.data.search.edges[].node | select(.number != null) | . + {prType: $t}]')
        all_results=$(echo "$all_results" "$page" | jq -sc '.[0] + .[1]')

        has_next=$(echo "$response" | jq -r '.data.search.pageInfo.hasNextPage')
        cursor=$(echo "$response" | jq -r '.data.search.pageInfo.endCursor // empty')
    done

    echo "$all_results"
}

categorize_and_format() {
    local authored_json="$1"
    local review_json="$2"

    local combined
    combined=$(echo "$authored_json" "$review_json" | jq -sc '.[0] + .[1]')

    echo "$combined" | jq -c --arg me "$MY_LOGIN" '
def is_bot: . as $login |
  ($login == "CharlieHelps" or $login == "charliecreates"
   or $login == "copilot-pull-request-reviewer" or $login == "linear"
   or ($login | startswith("app/")));

def ci_status:
  (.commits.nodes[0].commit.statusCheckRollup.contexts.nodes // []) as $ctx |
  if ($ctx | length) == 0 then "none"
  elif ($ctx | map(select(.conclusion == "FAILURE" or .state == "FAILURE")) | length) > 0 then "failing"
  elif ($ctx | map(select((.status // "") != "COMPLETED" and (.state // "") != "SUCCESS")) | length) > 0 then "pending"
  else "passing"
  end;

def last_commit_date:
  .commits.nodes[0].commit.committedDate // "1970-01-01T00:00:00Z";

def has_non_bot_activity_after_push:
  last_commit_date as $lcd |
  (
    [(.reviews.nodes // [])[] | select(.author.login | is_bot | not) | select(.author.login != $me) | .submittedAt] +
    [(.comments.nodes // [])[] | select(.author.login | is_bot | not) | select(.author.login != $me) | .createdAt]
  ) | map(select(. > $lcd)) | length > 0;

def latest_non_bot_activity:
  (
    [(.reviews.nodes // [])[] | select(.author.login | is_bot | not) | select(.author.login != $me) | .submittedAt] +
    [(.comments.nodes // [])[] | select(.author.login | is_bot | not) | select(.author.login != $me) | .createdAt]
  ) | max // null;

def kevin_reviewed:
  [(.reviews.nodes // [])[] | select(.author.login == $me)] | length > 0;

def kevin_last_review:
  [(.reviews.nodes // [])[] | select(.author.login == $me) | .submittedAt] | max // null;

def other_humans_active:
  [
    ((.reviews.nodes // [])[] | select(.author.login | is_bot | not) | select(.author.login != $me)),
    ((.comments.nodes // [])[] | select(.author.login | is_bot | not) | select(.author.login != $me))
  ] | length > 0;

def has_human_reviewer_assigned:
  [(.reviewRequests.nodes // [])[] | .requestedReviewer.login // null | select(. != null) | select(is_bot | not)] | length > 0;

def is_directly_requested:
  [(.reviewRequests.nodes // [])[] | .requestedReviewer.login // null | select(. == $me)] | length > 0;

def has_human_reviewed:
  [(.reviews.nodes // [])[] | select(.author.login | is_bot | not) | select(.author.login != $me)] | length > 0;

def reviewer_status:
  if has_human_reviewed then "human reviewed"
  elif has_human_reviewer_assigned then "human assigned"
  else "bot only"
  end;

def repo_from_url:
  .url | split("/") | .[-3];

def relative_time:
  if . == null then "unknown"
  else
    ((now - (. | gsub("[Z+].*$"; "") | strptime("%Y-%m-%dT%H:%M:%S") | mktime)) / 60 | floor) as $mins |
    if $mins < 60 then "\($mins)m ago"
    elif $mins < 1440 then "\(($mins / 60 | floor))h ago"
    else "\(($mins / 1440 | floor))d ago"
    end
  end;

.[] |
  repo_from_url as $repo |
  ci_status as $ci |
  if .prType == "authored" then
    if (.reviewDecision == "APPROVED" and $ci == "passing" and .mergeable == "MERGEABLE" and .isDraft == false) then
      . + {action: "ready-to-merge", repo: $repo, ciStatus: $ci}
    elif has_non_bot_activity_after_push then
      . + {action: "needs-response", repo: $repo, ciStatus: $ci, latestActivity: latest_non_bot_activity, lastPush: last_commit_date}
    elif $ci == "failing" then
      . + {action: "ci-failing", repo: $repo, ciStatus: $ci}
    elif .mergeable == "CONFLICTING" then
      . + {action: "merge-conflict", repo: $repo, ciStatus: $ci}
    else
      . + {action: "waiting", repo: $repo, ciStatus: $ci, reviewerStatus: reviewer_status}
    end
  else
    if kevin_reviewed then
      if (last_commit_date > kevin_last_review) then
        . + {action: "updated-since-review", repo: $repo, ciStatus: $ci, lastPush: last_commit_date, myLastReview: kevin_last_review}
      else
        . + {action: "response-pending", repo: $repo, ciStatus: $ci, myLastReview: kevin_last_review}
      end
    elif (other_humans_active or (is_directly_requested | not)) then
      . + {action: "needs-review-others", repo: $repo, ciStatus: $ci}
    else
      . + {action: "needs-review-sole", repo: $repo, ciStatus: $ci}
    end
  end
'
}

generate_markdown() {
    local categorized="$1"
    local authored_count
    authored_count=$(echo "$categorized" | jq -sc '[.[] | select(.prType == "authored")] | length')
    local review_count
    review_count=$(echo "$categorized" | jq -sc '[.[] | select(.prType != "authored")] | length')
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M")

    local md=""
    md+="# PR Triage"$'\n'
    md+="> Generated ${timestamp} | ${authored_count} authored, ${review_count} review requests"$'\n\n'
    md+="## My PRs"$'\n\n'

    local sections=("ready-to-merge:Ready to Merge:🟢" "needs-response:Needs Response:💬" "ci-failing:CI Failing:🔴" "merge-conflict:Merge Conflict:⚠️" "waiting:Waiting:⏳")
    for section in "${sections[@]}"; do
        local key="${section%%:*}"
        local rest="${section#*:}"
        local label="${rest%%:*}"
        local icon="${rest#*:}"
        local items
        items=$(echo "$categorized" | jq -sc --arg a "$key" '[.[] | select(.prType == "authored" and .action == $a)]')
        local count
        count=$(echo "$items" | jq 'length')
        if [ "$count" -eq 0 ]; then
            continue
        fi
        md+="### ${icon} ${label}"$'\n\n'
        local formatted
        formatted=$(echo "$items" | jq -r '.[] |
            def relative_time:
                if . == null then "unknown"
                else
                    ((now - (. | gsub("[Z+].*$"; "") | strptime("%Y-%m-%dT%H:%M:%S") | mktime)) / 60 | floor) as $mins |
                    if $mins < 60 then "\($mins)m ago"
                    elif $mins < 1440 then "\(($mins / 60 | floor))h ago"
                    else "\(($mins / 1440 | floor))d ago"
                    end
                end;
            "- **\(.repo)** [#\(.number)](\(.url)) \(.title)  \n" +
            if .action == "ready-to-merge" then
                "✅ `approved` · `CI passing` · +\(.additions)/-\(.deletions)"
            elif .action == "needs-response" then
                "💬 **comment \(.latestActivity | relative_time)** · last push \(.lastPush | relative_time)"
            elif .action == "ci-failing" then
                "❌ `CI failing` · last push \(.commits.nodes[0].commit.committedDate | relative_time)"
            elif .action == "merge-conflict" then
                "⚠️ `merge conflict`"
            elif .action == "waiting" then
                "`\(if .reviewDecision == "REVIEW_REQUIRED" then "in review" elif .isDraft then "draft" else .reviewDecision // "open" end)` · `CI \(.ciStatus)` · \(if .reviewerStatus == "bot only" then "⚠️ **no human reviewer**" elif .reviewerStatus == "human assigned" then "👤 assigned" else "👤 reviewed" end)"
            else ""
            end
        ')
        md+="${formatted}"$'\n\n'
    done

    md+="<!-- SECTION_BREAK -->"$'\n'
    md+="## Review Requested"$'\n\n'

    local rsections=("needs-review-sole:Needs My Review (sole reviewer):🔥" "needs-review-others:Needs My Review (others reviewing):👀" "updated-since-review:Updated Since Review:🔄" "response-pending:Response Pending:⏸️")
    for section in "${rsections[@]}"; do
        local key="${section%%:*}"
        local rest="${section#*:}"
        local label="${rest%%:*}"
        local icon="${rest#*:}"
        local items
        items=$(echo "$categorized" | jq -sc --arg a "$key" '[.[] | select(.prType != "authored" and .action == $a)] | sort_by(.updatedAt)')
        local count
        count=$(echo "$items" | jq 'length')
        if [ "$count" -eq 0 ]; then
            continue
        fi
        md+="### ${icon} ${label}"$'\n\n'
        local formatted
        formatted=$(echo "$items" | jq -r '.[] |
            def relative_time:
                if . == null then "unknown"
                else
                    ((now - (. | gsub("[Z+].*$"; "") | strptime("%Y-%m-%dT%H:%M:%S") | mktime)) / 60 | floor) as $mins |
                    if $mins < 60 then "\($mins)m ago"
                    elif $mins < 1440 then "\(($mins / 60 | floor))h ago"
                    else "\(($mins / 1440 | floor))d ago"
                    end
                end;
            "- **\(.repo)** [#\(.number)](\(.url)) \(.title)  \n" +
            if .action == "needs-review-sole" then
                "🔥 by **\(.author.login)** · opened \(.createdAt | relative_time) · updated \(.updatedAt | relative_time) · +\(.additions)/-\(.deletions) · **sole reviewer**"
            elif .action == "needs-review-others" then
                "👀 by \(.author.login) · `others reviewing` · updated \(.updatedAt | relative_time)"
            elif .action == "updated-since-review" then
                "🔄 by \(.author.login) · **pushed \(.lastPush | relative_time)** · updated \(.updatedAt | relative_time) · my review \(.myLastReview | relative_time)"
            elif .action == "response-pending" then
                "⏸️ by \(.author.login) · my review \(.myLastReview | relative_time) · updated \(.updatedAt | relative_time) · no new pushes"
            else
                "by \(.author.login)"
            end
        ')
        md+="${formatted}"$'\n\n'
    done

    echo "$md"
}

run_triage() {
    local authored
    authored=$(fetch_prs "is:pr is:open author:${MY_LOGIN} org:${OWNER}" "authored")

    local review_requested
    review_requested=$(fetch_prs "is:pr is:open review-requested:${MY_LOGIN} org:${OWNER}" "review-requested")

    local categorized
    categorized=$(categorize_and_format "$authored" "$review_requested")

    if [ "$FORMAT" = "json" ]; then
        echo "$categorized"
    else
        local md
        md=$(generate_markdown "$categorized")
        mkdir -p "$(dirname "$OUTPUT_FILE")"
        echo "$md" > "$OUTPUT_FILE"
        echo "Wrote $OUTPUT_FILE" >&2
        if ! $WATCH && command -v mdcat >/dev/null 2>&1; then
            local rule="════════════════════════════════════════════════════════════════════════════════"
            local tmp_top tmp_bot
            tmp_top=$(mktemp)
            tmp_bot=$(mktemp)
            sed -n '1,/<!-- SECTION_BREAK -->/p' "$OUTPUT_FILE" | sed '/<!-- SECTION_BREAK -->/d' > "$tmp_top"
            sed -n '/<!-- SECTION_BREAK -->/,$p' "$OUTPUT_FILE" | sed '1d' > "$tmp_bot"
            printf '\n\033[32m%s\033[0m\n\n' "$rule"
            mdcat --columns 120 "$tmp_top"
            printf '\n\033[33m%s\033[0m\n\n' "$rule"
            mdcat --columns 120 "$tmp_bot"
            printf '\n\033[31m%s\033[0m\n\n' "$rule"
            rm -f "$tmp_top" "$tmp_bot"
        elif ! $WATCH; then
            echo "View with: mdcat $OUTPUT_FILE" >&2
        fi
    fi
}

if $WATCH; then
    echo "Watching every ${WATCH_INTERVAL}m. Ctrl-C to stop." >&2
    while true; do
        run_triage
        echo "Updated $(date +%H:%M). Next in ${WATCH_INTERVAL}m..." >&2
        sleep "${WATCH_INTERVAL}m"
    done
else
    run_triage
fi
