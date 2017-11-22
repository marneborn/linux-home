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
    set firstCommand to "ttab \"postgres -D $PG_ROOT/data | tee $PG_ROOT/logfile\""
    do script firstCommand in targetWindow

    delay 1

    -- Start the aparment-app-service
    --tell application "System Events" to tell process "Terminal" to keystroke "t" using command down
    set secondCommand to "ttab \"cd $KEYO_ROOT/apartment-app-service; yarn watch\""
    do script secondCommand in tab 1 of targetWindow

    delay 10

    -- Start the admin-portal
    --tell application "System Events" to tell process "Terminal" to keystroke "t" using command down
    set thirdCommand to "ttab \"cd $KEYO_ROOT/keyo-web; yarn start\""
    do script thirdCommand in tab 1 of targetWindow

    -- postgres takes a while...
    delay 5
    -- Interactive postgres
    --tell application "System Events" to tell process "Terminal" to keystroke "t" using command down
    set fourthCommand to "ttab psql -d keyodb"
    do script fourthCommand in tab 1 of targetWindow

end tell

EOF
