import os
import urllib.request
import zipfile
import subprocess
import shutil

ENV_DIR = "/home/galal/android-build-env"
gradle_zip = os.path.join(ENV_DIR, "gradle.zip")
gradle_home = os.path.join(ENV_DIR, "gradle-8.4")

# 1. Download Gradle 8.4 if needed
if not os.path.exists(gradle_home):
    print("1. Downloading Gradle 8.4...", flush=True)
    urllib.request.urlretrieve("https://services.gradle.org/distributions/gradle-8.4-bin.zip", gradle_zip)
    print("2. Extracting Gradle 8.4...", flush=True)
    with zipfile.ZipFile(gradle_zip, 'r') as zip_ref:
        zip_ref.extractall(ENV_DIR)
else:
    print("Gradle 8.4 already exists.", flush=True)

# 2. Setup Environment Variables
java_home = os.path.join(ENV_DIR, "jdk-17.0.10+7")
android_home = os.path.join(ENV_DIR, "android-sdk")

env = os.environ.copy()
env["JAVA_HOME"] = java_home
env["ANDROID_HOME"] = android_home
env["PATH"] = f"{java_home}/bin:{gradle_home}/bin:{env['PATH']}"

# 3. Create settings.gradle.kts and root build.gradle.kts to make it a valid project
project_dir = "/home/galal/openwrt/alemprator-android-app"
settings_file = os.path.join(project_dir, "settings.gradle.kts")
with open(settings_file, "w") as f:
    f.write("""pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "alemprator-setup"
include(":app")
""")

root_build_file = os.path.join(project_dir, "build.gradle.kts")
with open(root_build_file, "w") as f:
    f.write("""
plugins {
    id("com.android.application") version "8.2.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false
}
""")

properties_file = os.path.join(project_dir, "gradle.properties")
with open(properties_file, "w") as f:
    f.write("android.useAndroidX=true\n")

# 4. Run gradle assembleDebug
print("3. Compiling Android APK using Gradle...", flush=True)
gradle_bin = os.path.join(gradle_home, "bin", "gradle")
os.chmod(gradle_bin, 0o755)

build_proc = subprocess.run(
    [gradle_bin, "assembleDebug"],
    cwd=project_dir,
    env=env,
    capture_output=True,
    text=True
)

print(build_proc.stdout, flush=True)
print(build_proc.stderr, flush=True)

if build_proc.returncode == 0:
    print("4. APK Compiled Successfully!", flush=True)
    # Copy APK to output
    apk_src = os.path.join(project_dir, "app", "build", "outputs", "apk", "debug", "app-debug.apk")
    apk_dest = "/home/galal/openwrt/alemprator-setup-app.apk"
    if os.path.exists(apk_src):
        shutil.copy(apk_src, apk_dest)
        print(f"Final APK is ready at: {apk_dest}", flush=True)
    else:
        print("Error: APK compiled but not found at expected path.", flush=True)
else:
    print(f"Error: Gradle compilation failed with return code {build_proc.returncode}", flush=True)
