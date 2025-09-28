---
title: python version conflict resolution
authors:
  - xman
date:
    created: 2019-12-02T11:00:00
categories:
    - python
tags:
    - py
    - venv
comments: true
---

The error "bad magic number in 'encodings'" indicates a fundamental Python version compatibility issue. This error occurs when Python attempts to load compiled bytecode (`.pyc` files) created by a different Python version.

<!-- more -->

## Problem Statement

My Windows system has Python 2.7 installed. The system is configured as follows:

- Python 2.7's bin path is added to the `Path` environment variable
- The directories `Scripts\`, `Scripts\Lib\`, and `Scripts\Lib\site-packages` are added to the `PYTHONPATH` environment variable

After installing Python 3.13.6 and navigating to its installation directory, `Python3 -V` works correctly, but running `Scripts\pip -V` produces this error:

```bash
Fatal Python error: Failed to import encodings module
Python runtime state: core initialized
ImportError: bad magic number in 'encodings': b'\xb3\xf2\r\n'
```

The existing Python 2.7 installation cannot be removed as it may be required by existing applications. We need a solution to manage both Python versions effectively.

## Root Cause Analysis

The error "bad magic number in 'encodings'" indicates a fundamental Python version compatibility issue. This error occurs when Python attempts to load compiled bytecode (`.pyc` files) created by a different Python version.

**Technical Explanation**:

Each Python version stamps its bytecode files with a unique "magic number" as a version identifier. Python 3.13.6 cannot interpret bytecode compiled by Python 2.7, resulting in this error.

**Specific Causes**:

1. The `PYTHONPATH` environment variable contains Python 2.7 directories
2. Python's module import system searches `PYTHONPATH` before standard library locations
3. When Python 3.13.6 starts, it finds Python 2.7's bytecode files first
4. The version mismatch in bytecode format causes the import failure

**Requirements**:

1. Maintain both Python versions without interference between them
2. Keep Python 2.7 functional for legacy applications
3. Establish a clean Python 3.13.6 environment for new development
4. Create a reliable, repeatable way to switch between versions

## Solution 1: Use Python Launcher for Windows (py.exe)

The Python Launcher (`py.exe`) is included with Python installations on Windows and provides a standardized way to manage multiple Python versions.

**Advantages**:

- Officially supported by Python
- No environment variable changes needed
- Preserves both Python installations intact

### Step 1: Verify Python Launcher Installation

```cmd
py --list
```

This command should display all installed Python versions, including both 2.7 and 3.13.6.

### Step 2: Use Version-Specific Commands

```cmd
# Use Python 2.7 specifically
py -2.7 --version
py -2.7 -m pip --version
py -2.7 your_legacy_script.py

# Use Python 3.13.6 specifically
py -3.13 --version
py -3.13 -m pip --version
py -3.13 -m pip install package_name
py -3.13 your_script.py
```

### Step 3: Create Default Version (Optional)

You can set a default Python version by creating a `py.ini` file or using shebang lines in your scripts:

```ini
# In %USERPROFILE%\py.ini or %PythonHome%\py.ini
[defaults]
python=3.13
```

With shebang lines in your scripts:

```python
#!/usr/bin/env python3
# or
#! python3.13
```

## Solution 2: Modify Environment Variables for Path Separation

**Current Issue**: The `PYTHONPATH` environment variable is configured with Python 2.7 directories, causing module import conflicts.

**Strategy**: Establish separate, version-specific environment variables and control import paths.

### Step 1: Clean Up PYTHONPATH

1. Open System Properties → Advanced → Environment Variables
2. Edit or temporarily disable `PYTHONPATH` by removing these entries:

   - `Scripts\`
   - `Scripts\Lib\`  
   - `Scripts\Lib\site-packages`

### Step 2: Create Version-Specific Environment Variables

```cmd
# Set these as system environment variables
PYTHON27_HOME=C:\Path\To\Python27
PYTHON313_HOME=C:\Path\To\Python313
PYTHON27_SCRIPTS=%PYTHON27_HOME%\Scripts
PYTHON313_SCRIPTS=%PYTHON313_HOME%\Scripts
```

[4. Using Python on Windows — 4.1.3. Installing Without UI](https://docs.python.org/3/using/windows.html#installing-without-ui)

Name | Description | Default
-----|-------------|--------
InstallAllUsers | Perform a system-wide installation. | 0
TargetDir | The installation directory | Selected based on InstallAllUsers
DefaultAllUsersTargetDir | The default installation directory for all-user installs | %ProgramFiles%\Python X.Y or <br/>%ProgramFiles(x86)%\Python X.Y
DefaultJustForMeTargetDir | The default install directory for just-for-me installs | %LocalAppData%\Programs\Python\PythonXY or <br/>%LocalAppData%\Programs\Python\PythonXY-32 or <br>%LocalAppData%\Programs\Python\PythonXY-64

> %LOCALAPPDATA% = %USERPROFILE%\AppData\Local\

### Step 3: Configure PATH with Version Priority

Modify the `PATH` environment variable to prioritize Python 3.13.6:

```
%PYTHON313_HOME%;%PYTHON313_SCRIPTS%;%PYTHON27_HOME%;%PYTHON27_SCRIPTS%;...
```

### Step 4: Create Version-Specific PYTHONPATH Variables (Optional)

```cmd
# Optional - for applications that rely on specific PYTHONPATH values
PYTHONPATH_27=%PYTHON27_HOME%\Scripts;%PYTHON27_HOME%\Scripts\Lib;%PYTHON27_HOME%\Scripts\Lib\site-packages
PYTHONPATH_313=%PYTHON313_HOME%\Scripts;%PYTHON313_HOME%\Scripts\Lib;%PYTHON313_HOME%\Scripts\Lib\site-packages
```

## Solution 3: Temporary Environment Overrides

This solution uses temporary environment modifications for Python sessions without permanently changing your system configuration.

**Advantages**:

- Non-intrusive to system settings
- Simple to implement
- Session-specific with no permanent changes

### Option A: Command-Line Environment Clearing

**For Windows Command Prompt**:

```cmd
# One-time temporary environment for a single command
set PYTHONPATH=
C:\Path\To\Python3.13.6\python.exe --version
C:\Path\To\Python3.13.6\Scripts\pip.exe --version

# For running a script with clear environment
set PYTHONPATH=
C:\Path\To\Python3.13.6\python.exe your_script.py
```

**For PowerShell**:

```powershell
# Clear PYTHONPATH for Python 3 commands
$env:PYTHONPATH = ""
C:\Path\To\Python3.13.6\python.exe --version
C:\Path\To\Python3.13.6\Scripts\pip.exe --version
```

### Option B: Session Environment Batch File

Create a batch file named `set_py3_env.bat`:

```batch
@echo off
echo Activating Python 3.13.6 environment...
set PYTHONPATH=
set PATH=C:\Path\To\Python3.13.6;C:\Path\To\Python3.13.6\Scripts;%PATH%
cmd /k echo Python 3.13.6 environment is now active
```

Run this batch file to start a new command prompt with the Python 3.13.6 environment configured. All commands in this session will use Python 3.13.6 by default.

Given that the Python Installation Directory TargetDir/DefaultJustForMeTargetDir (`echo %PYTHON313_HOME%`) is `%LocalAppData%\Programs\Python\Python313`, we can create a sibling shims directory at `%LocalAppData%\Programs\Python\shims` (i.e., `%PYTHON313_HOME%\..\shims`) to house the batch file.

## Solution 4: Command Wrappers for Seamless Version Switching

**Strategy**: Create dedicated wrapper scripts that automatically handle environment setup and version selection.

**Advantages**:
- Minimal typing for everyday use
- Consistent command experience
- Prevents accidental version mixing

### Step 1: Create Wrapper Batch Files

#### `python3.bat` - Python 3.13 Wrapper

```batch
@echo off
setlocal          # Start local environment scope
set PYTHONPATH=   # This change is LOCAL only
py -3.13 %*       # Execute Python with local environment
endlocal          # Restore original environment
```

#### `pip3.bat` - Pip for Python 3.13 Wrapper

```batch
@echo off
setlocal
set PYTHONPATH=
py -3.13 -m pip %*
endlocal
```

#### `python2.bat` - Python 2.7 Wrapper (Optional)

```batch
@echo off
setlocal
set PYTHONPATH=%PYTHON27_HOME%\Scripts;%PYTHON27_HOME%\Scripts\Lib;%PYTHON27_HOME%\Scripts\Lib\site-packages
py -2.7 %*
endlocal
```

### Step 2: Add Wrappers to PATH

1. Place these batch files in a dedicated directory designated for housing wrapper shims, in accordance with Solution 3, specifically `%PYTHON313_HOME%\..\shims` (which resolves to `%LocalAppData%\Programs\Python\shims`).
2. Include the dedicated directory in your PATH environment variable to make these wrapper scripts globally accessible. This will allow you to easily call these wrapper scripts from anywhere.

### Step 3: Usage Examples

```batch
# Launch Python 3.13.6 interactive shell
python3

# Run Python 3.13.6 script
python3 script.py

# Execute Python 3.13.6 code directly
python3 -c "print('Hello, Python 3.13.6!')"

# Install packages with Python 3.13.6 pip
pip3 install requests
pip3 install --upgrade numpy

# Run a module with Python 3.13.6
python3 -m venv my_venv
python3 -m http.server 8000
```

The wrapper approach provides the familiarity of `python` and `pip` commands while ensuring the correct Python version and environment are used.

## Solution 5: Virtual Environments (Recommended Approach)

**Virtual environments** are the Python community's standard approach for isolating project dependencies and Python versions.

**Key Benefits**:

1. **Project Isolation** - Each project has its own dependencies and Python version
2. **Zero System Conflicts** - No interference with system Python installations
3. **Reproducible Environments** - Easy to recreate environments across machines
4. **Simple Version Switching** - Activate different environments as needed

### Python 3.13.6 Virtual Environments

```cmd
# Navigate to your project directory
cd D:\path\to\your_project

# Create a virtual environment using the built-in venv module
py -3.13 -m venv venv_py313

# Activate the virtual environment
venv_py313\Scripts\activate

# Verify Python and pip versions (should show 3.13.6)
python --version
pip --version

# Install project dependencies
pip install -r requirements.txt
# or
pip install package1 package2 package3

# Save your environment dependencies
pip freeze > requirements.txt

# Deactivate when done
deactivate
```

### Activation Shortcuts

Create a project-specific activation script `activate_project.bat`:

```batch
@echo off
echo Activating Python 3.13.6 environment for ProjectName...
call D:\path\to\your_project\venv_py313\Scripts\activate.bat
cd D:\path\to\your_project
echo Environment activated! Type 'deactivate' when finished.
```

### Python 2.7 Virtual Environments

For Python 2.7 projects, use the `virtualenv` package:

```cmd
# Navigate to your project directory
cd D:\path\to\legacy_project

# Install virtualenv for Python 2.7
py -2.7 -m pip install virtualenv

# Create Python 2.7 virtual environment
py -2.7 -m virtualenv venv_py27

# Activate the environment
venv_py27\Scripts\activate

# Verify Python and pip versions (should show 2.7.x)
python --version
pip --version

# Install dependencies
pip install -r requirements.txt

# Deactivate when done
deactivate
```

## Comparison of Solutions

| Solution | Complexity | Permanence | Best For | Limitations |
|----------|------------|------------|----------|------------|
| Python Launcher | Low | No system changes | Quick version switching | Requires explicit version flags |
| Environment Variables | Medium | System-wide changes | Global preference setup | Can affect other applications |
| Temp Environment Overrides | Low | Session-only | One-off commands | Must be repeated each session |
| Command Wrappers | Low | Command shortcuts only | Daily development | Needs PATH configuration |
| Virtual Environments | Medium | Project-specific | Professional development | Requires activation/deactivation |

## References

### Official Documentation

- [Using Python on Windows](https://docs.python.org/3/using/windows.html) - Official Python documentation
- [Python Launcher for Windows](https://docs.python.org/3/using/windows.html#python-launcher-for-windows) - py.exe documentation
- [Virtual Environments and Packages](https://docs.python.org/3/tutorial/venv.html) - Official venv documentation

### Python Installation

1. Always install launcher for all users (recommended)
2. Consider whether to add Python to `PATH` based on your needs

![Python Installation Options](https://docs.python.org/3/_images/win_installer.png)

### Additional Resources

- [PEP 397 – Python launcher for Windows](https://peps.python.org/pep-0397/)
- [Managing Multiple Python Versions with pyenv](https://github.com/pyenv/pyenv)
- [pipenv: Python Development Workflow for Humans](https://pipenv.pypa.io/)
- [Python版本控制工具 py launcher-CSDN博客](https://blog.csdn.net/Zhangguohao666/article/details/105632475)
