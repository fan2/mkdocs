---
title: brew python-pip install failed
authors:
  - xman
date:
    created: 2019-12-05T16:00:00
categories:
    - python
tags:
    - pip
    - venv
comments: true
---

macOS 下通过 brew 安装的 python3 包，尝试使用 pip3 命令安装软件包或升级过期包，会报错 `externally-managed-environment`。

<!-- more -->

```bash
error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try brew install
    xyz, where xyz is the package you are trying to
    install.
    
    If you wish to install a Python library that isn't in Homebrew,
    use a virtual environment:
    
    python3 -m venv path/to/venv
    source path/to/venv/bin/activate
    python3 -m pip install xyz
    
    If you wish to install a Python application that isn't in Homebrew,
    it may be easiest to use 'pipx install xyz', which will manage a
    virtual environment for you. You can install pipx with
    
    brew install pipx
    
    You may restore the old behavior of pip by passing
    the '--break-system-packages' flag to pip, or by adding
    'break-system-packages = true' to your pip.conf file. The latter
    will permanently disable this error.
    
    If you disable this error, we STRONGLY recommend that you additionally
    pass the '--user' flag to pip, or set 'user = true' in your pip.conf
    file. Failure to do this can result in a broken Homebrew installation.
    
    Read more about this behavior here: <https://peps.python.org/pep-0668/>

note: If you believe this is a mistake, please contact your Python installation or OS distribution provider. You can override this, at the risk of breaking your Python installation or OS, by passing --break-system-packages.
hint: See PEP 668 for the detailed specification.
```

The `externally-managed-environment` error occurs because your Python installation is managed by your system (likely Homebrew on macOS) and it **prevents** direct pip installations to avoid conflicts with system packages.

> Homebrew's Python installation uses PEP 668 to prevent system-wide pip installations that could conflict with Homebrew-managed packages, ensuring system stability.

Here are several solutions, ordered by recommendation.

## Solution 1: Use Virtual Environments

For packages not in Homebrew or for project-specific installations, create isolated environments for your projects:

```bash
# Create a virtual environment
python3 -m venv ~/my-python-env

# Activate it
source ~/my-python-env/bin/activate

# Now your original command will work
pip list --outdated | awk 'NR>2 {print $1}' | xargs -n1 pip install -U

# When done, deactivate
deactivate
```

If you want a general-purpose Python environment that you can reuse:

```bash
# Create a global virtual environment
python3 -m venv ~/.global-python-env

# Add activation to your shell profile for easy access
echo 'alias activate-python="source ~/.global-python-env/bin/activate"' >> ~/.zshrc
source ~/.zshrc

# Now you can easily activate it anytime
activate-python

# Run your upgrade command
pip list --outdated | awk 'NR>2 {print $1}' | xargs -n1 pip install -U
```

## Solution 2: Use pipx for Command-Line Tools

[pipx · PyPI](https://pypi.org/project/pipx/) - [Documentation](https://pipx.pypa.io/stable/)

For standalone applications/tools:

```bash
# Install pipx first (if not already installed)
brew install pipx

# Install packages in isolated environments
pipx install package_name

# Upgrade packages
pipx upgrade package_name
```

## Solution 3: Use --user Flag (Still Report Same Error)

Install packages to your user directory:

```bash
pip3 install --user -U package_name
```

> `--user`: Install to the Python user install directory for your platform. Typically `~/.local/`, or `%APPDATA%\Python` on Windows. (See the Python documentation for site.USER_BASE for full details.)

## Solution 4: Use --break-system-packages (Not Recommended)

Force pip to ignore the restriction (risky):

```bash
pip3 install --break-system-packages -U package_name
```

**Best Practice**: I recommend using virtual environments for project-specific dependencies and pipx for command-line tools. This keeps your system Python clean and avoids dependency conflicts.
