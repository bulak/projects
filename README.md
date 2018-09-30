# projects

Simple project management for bash CLI as a soft 
wrapper for terminal multiplexers (tmux or screen).

## Features

- Support for either `tmux` or `screen`. Simply init, resume,
save or kill projects from CLI. `projects` will remember
paths, layouts, histories for you
- Eternal bash history. Keep ALL your bash history, also
separately for each project with time and full path stamps
- Journaling. Keep notes per project simply from CLI

## Installation

```bash
git clone https://github.com/bulak/projects.git
cd projects
./install.sh
```

## Functionality

### To initiate a project

Simply go to the directory where the project will live, and call
`projects init PROJECT_NAME`:

```bash
:~$ cd /path/to/my_project
:~/path/to/my_project$ projects init MyProject
```

This will initiate a tmux (or screen, depending on install choice)
session named MyProject and will include two environmental variables,
`$PROJECT_NAME` and `$PROJECT_HOME`.

The session could be either detached or killed. `projects` will remember
the project path even if the session was quitted.

### To resume/attach to a project

From anywhere, call `resume`  with project's name:

```bash
:~/some/directory/$ projects resume MyProject
```
This will attach to the session if it is active, or start a new session
with the project's name.

### Global eternal history

If the *eternal history* option was selected during installation,
several `bash` functions will become available:

  - `ehist` eternal history, is available everywhere and displays your
    eternal history (all your bash activity since installation of
    `projects`). The eternal history file,
    `~.history/bash_history-${HOSTNAME}`, will keep growing as long as
    the `~/.bashrc_projects` is sourced from your `.bashrc` config. Default
    `ehist` is configured to color the output of your history:

  - `hnote` appends a special note to your eternal history that could be
    used for locating, parsing etc:

```bash
:~$ hnote "This is just a note for myself"
:~$ ehist
```
...
![ehist](https://raw.githubusercontent.com/bulak/projects//ehist_screenshot.png)

### Inside a project

  - `phist` project history, is available within a project and displays
    the eternal history of that project only. In addition to time and
    path stamps of `ehist`, it also lists the pane# of the multiplexer
    session where the command has been executed.

![phist](https://raw.githubusercontent.com/bulak/projects/fdd17f319424adbf76c36a3c03255ded770ed1e8/phist_screenshot.png)

  - `pnote` is available only within a project and similar to `hnote`
    produces a note within the project's eternal history. The note will
    only be available in that project and not in global eternal history.

If *journaling* option was selected during install, additional commands
will be available from within a project:

  - `add_jrnl` and `pj` are available if journaling option is selected
    during installation. These commands depend on `jrnl` package
    (python, link).

    `add_jrnl` adds a project-specific journal to user's journal database.

    `pj` is an alias for `jrnl ${PROJECT_NAME}`` which simply enables
    viewing and editing of project specific notes. Basic usage:

For further functionality of `jrnl` check out ....

### Terminating a project

|projects kill PROJECT_NAME|

### Listing projects

`projects list` `projects info PROJECT_NAME`


### Layouts

When a project is initiated, an additional LAYOUT argument can be
supplied to the `init` command:

```bash
:~/path/to/my_project$ projects init WebMonitor monitor
```

This would look for a layout file under `~/.projects/layouts/` with a
name that depends on the multiplexer used:
`monitor.(tmux|screen).layout`. The layout files are basically
extensions to `.tmuxrc` or `.screenrc` where splitting, default commands
etc can be organized.

The layout file is only used once during initialization and if a project
is resumed after its multiplexer session is terminated, it will not be
used again. This could be feature that can be implemented in future.

Look at these resources for further ideas about how to write layout
files: refs...

### Files and directories

| Default path | Explanation |
| --- | --- |
| ~/.local/bin/projects | main bash script, 'tmux' or 'screen' support is
selected during installation |
| ~/.bashrc_projects | sourced by ~.bashrc and provides all bash functions |
| ~/.local/bin/add_jrnl | /optional/ python script for project specific
journaling |
| ~/.projects/ | main path where all projects' data and lock files are stored |
| ~/.projects/layouts/ | layout directory |
| ~/.history/ | eternal history directory for both global and project specific command histories |

