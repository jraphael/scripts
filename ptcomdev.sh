default_dir="ptcomdev"
args=("$@")
hostname = "ptcomdev"
dir=""
user=""

# Sets dir variable with the default directory if args is empty.
#
if [ -z "${args}" ]; then
  dir=${default_dir} 
else
  dir=${args[0]}
fi

# Creates a new directory if necessary.
#
if [ ! -d ${dir} ]; then
  mkdir ~/${dir}
  echo ${dir} "<- directory created!"
fi

# Mounts the directory.
#
if [ -d ${dir} ]; then
  sshfs ${hostname}:/home/${user} ~/${dir} -o auto_cache -o follow_symlinks -o volname=${dir}
  echo ${dir} "<- and mounted!"
fi
