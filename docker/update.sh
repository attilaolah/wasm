# To be called from the Docker container.
# DO NOT RUN outside of the Docker container.

# Prevent Apt from asking too many questions.
export DEBIAN_FRONTEND=noninteractive

# First do a system upgrade.
apt-get update
apt-get --yes dist-upgrade 2>&1

# Install Bazel:
# https://docs.bazel.build/versions/master/install-ubuntu.html#install-on-ubuntu
apt-get --yes install apt-transport-https curl gnupg 2>&1
curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/bazel.gpg
echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" >> /etc/apt/sources.list.d/bazel.list
apt-get update
apt-get --yes install bazel 2>&1

# Required by //lib/openssl:
apt-get --yes install libfindbin-libs-perl 2>&1

# Required by //lib/cblas:
apt-get --yes install gfortran 2>&1

# Required by //lib/grass:
apt-get --yes install python3-distutils python3-six gettext 2>&1

# Self-destruct.
rm /etc/update.sh
