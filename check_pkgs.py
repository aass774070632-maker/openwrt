import os

archs = ["mipsel_24kc", "aarch64_cortex-a53"]
targets = ["luci-app-cpu-status", "luci-app-cpu-perf", "luci-app-temp-status", "luci-app-log-viewer", "luci-app-tn-netports", "luci-app-netspeedtest", "luci-app-bandix-plus", "bandix-plus"]
base_dir = "bin/packages"

# Standard packages that might be in target folder or provided by toolchain
IGNORED_DEPS = {"libc", "librt", "libpthread", "libstdcpp"}

all_missing_related = set()

for arch in archs:
    print(f"--- {arch} ---")
    pkg_info = {}
    arch_path = os.path.join(base_dir, arch)
    if not os.path.exists(arch_path):
        print(f"Directory {arch_path} not found")
        continue

    for root, dirs, files in os.walk(arch_path):
        if "Packages" in files:
            pkg_file = os.path.join(root, "Packages")
            with open(pkg_file, 'r', errors='ignore') as f:
                content = f.read().split("\n\n")
                for block in content:
                    lines = block.splitlines()
                    name = ""
                    filename = ""
                    depends = ""
                    for line in lines:
                        if line.startswith("Package: "):
                            name = line[9:].strip()
                        elif line.startswith("Filename: "):
                            filename = line[10:].strip()
                        elif line.startswith("Depends: "):
                            depends = line[9:].strip()
                    if name:
                        pkg_info[name] = {"filename": os.path.join(root, filename), "depends": depends}

    print(f"{'Target Package':<25} | {'Missing Deps':<20} | {'Missing Dep Art':<20} | {'Missing Target Art'}")
    print("-" * 100)
    
    for target in targets:
        missing_deps = []
        missing_dep_arts = []
        missing_target_art = "NO"
        
        if target not in pkg_info:
            missing_target_art = "YES (Not in Index)"
            all_missing_related.add(target)
        else:
            if not os.path.exists(pkg_info[target]["filename"]):
                missing_target_art = "YES (File Missing)"
                all_missing_related.add(target)
            
            deps_line = pkg_info[target]["depends"]
            if deps_line:
                deps = [d.strip() for d in deps_line.split(",")]
                for dep in deps:
                    if dep.startswith("@"): continue
                    
                    found_any = False
                    found_file = False
                    alts = [a.strip() for a in dep.split("|")]
                    for alt in alts:
                        alt_name = alt.split("(")[0].strip()
                        if alt_name in IGNORED_DEPS:
                             found_any = True
                             found_file = True
                             break
                        if alt_name in pkg_info:
                            found_any = True
                            if os.path.exists(pkg_info[alt_name]["filename"]):
                                found_file = True
                                break
                    
                    if not found_any:
                        missing_deps.append(dep)
                        all_missing_related.add(dep)
                    elif not found_file:
                        missing_dep_arts.append(dep)
                        all_missing_related.add(dep)

        print(f"{target:<25} | {', '.join(missing_deps):<20} | {', '.join(missing_dep_arts):<20} | {missing_target_art}")
    print("\n")

print("Deduplicated list of missing/incorrectly built related packages:")
print(", ".join(sorted(list(all_missing_related))))
