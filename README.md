# histctx

A tool to make context switching easier by creating and managing multiple bash histories!

```bash
$ histctx help
usage: histctx <command|context> [<args>]

COMMANDS
  set                      set a context, create it if it doesn't exists yet. "/usr/local/bin/histctx set ." expands "." as the current folder name
  temporary|tmp            create a context in /tmp and set it as current
  list|ls                  list existing history contexts, can use the same flags as the sort command
  show|cat                 show history of given contexts, or all histories if no argument is given
  rename|mv                rename an history context
  delete|del|remove|rm     delete an history context
  help                     show this help message

EXAMPLES
  $ histctx set new-context
  $ histctx set .
  $ histctx tmp
        $ histctx list -rk 3 # list sorted by name (third column) in reverse order
  $ histctx show my-context another-context
  $ histctx rename new-context my-context
  $ histctx delete my-context
```

## Implementation

It uses the [`$HISTFILE`](https://www.gnu.org/software/bash/manual/html_node/Bash-History-Facilities.html) environment variable to set the location of your bash history based on the choosen "context". Histories are kept in `~/.bash_history.d/<CONTEXT_NAME>` directory.
