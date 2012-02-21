  # use CAUTION - script written by ubuntu newbie
  # script builds required environment for opentop build-from-src on official ubuntu 10.10 64 bit amazon ebs ami
  # assumes you are sshing into instance from ubuntu 10.10 desktop
  # while in desktop ubuntu, scp out the /etc/apt/sources list
  scp  -i /host/personal/bikram/openSource/apache_bigtop/aws/ec2/ubuntu_10_04_official/ubuntu_1004_official.pem /etc/apt/sources.list ubuntu@ec2-xxx-xxx-xxx-xxx.us-west-1.compute.amazonaws.com:/home/ubuntu
  # now ssh into instance
  ssh -i /host/personal/bikram/openSource/apache_bigtop/aws/ec2/ubuntu_10_04_official/ubuntu_1004_official.pem ubuntu@ec2-xxx-xxx-xxx-xxx.us-west-1.compute.amazonaws.com
  # clobber sources.list- 
  # the instance currently uses ec2-us-west1.ubuntu as repository hosts. use standard 10.10 instead, otherwise i had to do apt-get install --fix-missing
  # a better way could have been to move it to sources.list.d instead. i am just being lazy.
  sudo mv sources.list /etc/apt
  sudo apt-get update
  # install miminal build tools required
  sudo apt-get install -y git-core git-svn subversion build-essential checkinstall dh-make debhelper devscripts autoconf automake liblzo2-dev libzip-dev sharutils libfuse-dev  libssl-dev libtool reprepro ant ant-optional
  # given the repository structure, ant will make openJDK6 the default jvm. override with Oracle jdk6_31 64 bit below 
  mkdir downloads
  cd downloads
  wget http://download.oracle.com/otn-pub/java/jdk/6u31-b04/jdk-6u31-linux-x64.bin
  chmod a+x jdk-6u31-linux-x64.bin 
  ./jdk-6u31-linux-x64.bin 
  sudo mv jdk1.6.0_31 /usr/lib/jvm
  sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.6.0_31/bin/java" 2
  sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.6.0_31/bin/javac" 2
  sudo update-alternatives --config java --rem choose the highest possible numeric value, when prompted
  # download and install apache-forrest and mvn 3.0
  sudo wget http://apache.deathculture.net//maven/binaries/apache-maven-3.0.4-bin.tar.gz
  sudo tar -xzvf apache-maven-3.0.4-bin.tar.gz 
  sudo mkdir /usr/local/maven-3
  sudo mv apache-maven-3.0.4 /usr/local/maven-3/
  wget http://archive.apache.org/dist/forrest/0.8/apache-forrest-0.8.tar.gz
  tar -xzvf apache-forrest-0.8.tar.gz 
  # modify certain lines in the forrest-validate xml, otherwise build fails.
  sed -i 's/property name="forrest.validate.sitemap" value="${forrest.validate}"/property name="forrest.validate.sitemap" value="false"/g' apache-forrest-0.8/main/targets/validate.xml
  sed -i 's/property name="forrest.validate.stylesheets" value="${forrest.validate}"/property name="forrest.validate.stylesheets" value="false"/g' apache-forrest-0.8/main/targets/validate.xml
  sed -i 's/property name="forrest.validate.stylesheets.failonerror" value="${forrest.validate.failonerror}"/property name="forrest.validate.stylesheets.failonerror" value="false"/g' apache-forrest-0.8/main/targets/validate.xml
  sed -i 's/property name="forrest.validate.skins.stylesheets" value="${forrest.validate.skins}"/property name="forrest.validate.skins.stylesheets" value="false"/g' apache-forrest-0.8/main/targets/validate.xml
  # setup environment variables for use by the build process
  sudo sed -i '1i JAVA_HOME="/usr/lib/jvm/jdk1.6.0_31"' /etc/environment
  sudo sed -i '2i JAVA5_HOME="/usr/lib/jvm/jdk1.6.0_31"' /etc/environment
  sudo sed -i '3i FORREST_HOME="/home/ubuntu/downloads/apache-forrest-0.8"' /etc/environment
  sudo sed -i '4i M3_HOME="/usr/local/maven-3/apache-maven-3.0.4"' /etc/environment
  sudo sed -i '5i MAVEN_HOME="/usr/local/maven-3/apache-maven-3.0.4"' /etc/environment
  sudo sed -i '6i M3="/usr/local/maven-3/apache-maven-3.0.4/bin"' /etc/environment
  sudo sed -i '/PATH/d' /etc/environment
  sudo sed -i '7i PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/lib/jvm/jdk1.6.0_31:/usr/local/maven-3/apache-maven-3.0.4/bin"' /etc/environment
  # download opentop src from trunk, taking a minimal set of revisions 
  git svn clone  --no-minimize-url -r 1240010:HEAD https://svn.apache.org/repos/asf/incubator/bigtop/trunk
  # build a few sample packages or use screen if you want to build in parallel
  cd trunk
  screen
  make hadoop-deb
  ctrl+A
  make hbase-deb
  
