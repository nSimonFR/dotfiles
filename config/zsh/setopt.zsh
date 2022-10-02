# ===== Basics
setopt AUTO_CD # If you type foo, and it isn't a command, and it is a directory in your cdpath, go there
setopt INTERACTIVE_COMMENTS # Allow comments even in interactive shells (especially for Muness)

# ===== History
setopt APPEND_HISTORY # Allow multiple terminal sessions to all append to one zsh command history
setopt INC_APPEND_HISTORY # Add comamnds as they are typed, don't wait until shell exit
setopt HIST_IGNORE_DUPS # Do not write events to history that are duplicates of previous events
setopt HIST_FIND_NO_DUPS # When searching history don't display results already cycled through twice
setopt HIST_REDUCE_BLANKS # Remove extra blanks from each command line being added to history
setopt EXTENDED_HISTORY # Include more information about when the command was executed, etc

# ===== Completion
setopt COMPLETE_IN_WORD # Allow completion from within a word/phrase
setopt ALWAYS_TO_END # When completing from the middle of a word, move the cursor to the end of the word

# ===== Prompt
# Enable parameter expansion, command substitution, and arithmetic expansion in the prompt
setopt PROMPT_SUBST
unsetopt MENU_COMPLETE
setopt AUTO_MENU
