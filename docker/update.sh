# To be called from the Docker container.
# DO NOT RUN outside of the Docker container.

# First do a system upgrade.
apt-get update
apt-get --yes dist-upgrade 2>&1

# Install Bazel, and:
# - GNU M4, required by //lib/gmp. (Maybe add this to //tools some day.)
# https://docs.bazel.build/versions/master/install-ubuntu.html#install-on-ubuntu
apt-get --yes install curl gnupg 2>&1
curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/bazel.gpg
echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" >> /etc/apt/sources.list.d/bazel.list
apt-get update
apt-get --yes install bazel m4 2>&1

# TODO: Required by //lib/cblas, to be added to the build system.
apt-get --yes install gfortran

# TODO: Required by //lib/grass, to be added to the build system.
apt-get --yes install python3-distutils python3-six bison flex gettext 2>&1

# Self-destruct.
rm /etc/update.sh
