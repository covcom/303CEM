
# Job Control

When you run a command in the terminal it runs in the foreground which means you don't get control of the command prompt. Linux is capable of running multiple process (sort of) concurrently so how can we run multiple processes?

```
example needed...
```

Putting a program in the background.

We can put a program in the background by adding an ampersand (&) character to the end of the command we want to run. By doing this the prompt returns because the process was put in the background.
```
example needed.
```
If we want to put an _already running program_ in the background this can be achieved using the `bg` command, but the program will need to be suspended (paused) using `ctrl+z` before this is done.
```
example needed.
```
It is also possible to bring a background process into the foreground using the `fg` command. To see the jobs currently in the background use the `jobs` command. Each job is assigned a number such as `[1]`. To bring this job into the foreground you would use the `fg %1` command.
```
example needed
```

Killing a process.

If a program becomes unresponsive you can stop it using the `kill` command and passing the correct process ID (PID). These are shown when you run the `jobs` command and can also be seen if you run the `ps` command. You can either kill a job using its id `kill %1` or using its PID `kill 1234`.

Reference: http://linuxcommand.org/lts0080.php