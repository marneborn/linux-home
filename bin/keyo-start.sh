. ~/bin/keyo-setup.sh

osascript <<EOF
tell application "Terminal"
    -- Activate it.
    activate

    do script ""
    set targetWindow to window 1

    tell selected tab of targetWindow
    set background color to {13364,43176,21331}
    end tell

    -- Start postgres
    set firstCommand to "postgres -D $PG_ROOT/data | tee $PG_ROOT/logfile"
    do script firstCommand in targetWindow

    delay 1

    -- Start the aparment-app-service
    tell application "System Events" to tell process "Terminal" to keystroke "t" using command down
    set secondCommand to "cd $KEYO_ROOT/apartment-app-service; yarn watch"
    do script secondCommand in targetWindow

    delay 1

    -- Start the admin-portal
    tell application "System Events" to tell process "Terminal" to keystroke "t" using command down
    set secondCommand to "cd $KEYO_ROOT/keyo-web; yarn start"
    do script secondCommand in targetWindow

    -- postgres takes a while...
    delay 5
    -- Interactive postgres
    tell application "System Events" to tell process "Terminal" to keystroke "t" using command down
    set secondCommand to "psql -d keyodb"
    do script secondCommand in targetWindow

end tell

EOF
