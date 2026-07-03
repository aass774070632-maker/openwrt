import os
import urllib.request
import tarfile
import zipfile
import subprocess
import sys

ENV_DIR = "/home/galal/android-build-env"
os.makedirs(ENV_DIR, exist_ok=True)

# 1. Download JDK 17
jdk_url = "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10%2B7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.10_7.tar.gz"
jdk_tar = os.path.join(ENV_DIR, "jdk17.tar.gz")
print("1. Downloading JDK 17...", flush=True)
if not os.path.exists(jdk_tar):
    urllib.request.urlretrieve(jdk_url, jdk_tar)
else:
    print("JDK tar already exists.", flush=True)

# 2. Extract JDK 17
print("2. Extracting JDK 17...", flush=True)
if not os.path.exists(os.path.join(ENV_DIR, "jdk-17.0.10+7")):
    with tarfile.open(jdk_tar, "r:gz") as tar:
        tar.extractall(path=ENV_DIR)

# Setup java environment variables
java_home = os.path.join(ENV_DIR, "jdk-17.0.10+7")
os.environ["JAVA_HOME"] = java_home
os.environ["PATH"] = f"{java_home}/bin:{os.environ['PATH']}"

# 3. Download Android Command Line Tools
cmd_url = "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
cmd_zip = os.path.join(ENV_DIR, "cmdtools.zip")
print("3. Downloading Android Commandline Tools...", flush=True)
if not os.path.exists(cmd_zip):
    urllib.request.urlretrieve(cmd_url, cmd_zip)
else:
    print("Command line tools zip already exists.", flush=True)

# 4. Extract Command Line Tools
sdk_dir = os.path.join(ENV_DIR, "android-sdk")
cmdline_dest = os.path.join(sdk_dir, "cmdline-tools")
os.makedirs(cmdline_dest, exist_ok=True)

print("4. Extracting Commandline Tools...", flush=True)
if not os.path.exists(os.path.join(cmdline_dest, "latest")):
    with zipfile.ZipFile(cmd_zip, 'r') as zip_ref:
        zip_ref.extractall(cmdline_dest)
    # The zip extracts into cmdline-tools/cmdline-tools. Rename it to latest
    os.rename(os.path.join(cmdline_dest, "cmdline-tools"), os.path.join(cmdline_dest, "latest"))

# Setup Android SDK environment variables
android_home = sdk_dir
os.environ["ANDROID_HOME"] = android_home
os.environ["PATH"] = f"{android_home}/cmdline-tools/latest/bin:{android_home}/platform-tools:{os.environ['PATH']}"

# 5. Accept licenses and install platform-tools, build-tools, platforms
sdkmanager_path = os.path.join(android_home, "cmdline-tools", "latest", "bin", "sdkmanager")
# Make sdkmanager executable
os.chmod(sdkmanager_path, 0o755)

print("5. Accepting Android Licenses...", flush=True)
# Pass 'y' to license prompt
license_proc = subprocess.Popen([sdkmanager_path, "--licenses"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
# Send yes to all prompts
stdout, stderr = license_proc.communicate(input="y\ny\ny\ny\ny\ny\ny\n")
print(stdout, flush=True)

print("6. Installing platforms;android-34 and build-tools;34.0.0...", flush=True)
install_proc = subprocess.run([sdkmanager_path, "platforms;android-34", "build-tools;34.0.0", "platform-tools"], capture_output=True, text=True)
print(install_proc.stdout, flush=True)

print("Environment Setup Completed Successfully!", flush=True)
