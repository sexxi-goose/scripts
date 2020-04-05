# Useful scripts

- Currently just a simple script to help build on CSC or student CS servers.

## Getting Started

- Run `init_env.sh` to configure your Waterloo username and preferred build server.
- For making it easier to use the build script, setup an ssh key for your local machine and append your public key to `$HOME/.ssh/authorized_keys` and make sure that the key is added to your local ssh-agent. `ssh-agent -k $PATH_TO_KEY`.
- Run `echo "source $(pwd)/build_script.sh" >> SHELL_CONFIG_PATH`

## Build script
- Run `sg_rust_build -h` for available options.
