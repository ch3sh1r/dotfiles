if status is-interactive
    # Run ssh agent plugin
    fish_ssh_agent

    # Set up session logging
    #if test -z "$SCRIPTED"
        #set -gx SCRIPTED nested
        #set script_share "$HOME/.local/share/fish/scripts"
        #mkdir -p $script_share
        #script -q $script_share/(date +%s)
        #echo WARNING: session is no longer being captured
    #end
end
