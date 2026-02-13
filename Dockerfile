# Playwright Java - Red Hat Linux Docker Image (Fixed)
FROM registry.access.redhat.com/ubi8/ubi:latest

# Metadata
LABEL maintainer="Senthil Kumar Balarajendiran" \
      description="Playwright Java Automation on Red Hat UBI 8 with Maven Binaries 3.9.12 and Playwright CLI" \
      version="1.0"

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk \
    MAVEN_HOME=/opt/maven

ENV PATH="${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${PATH}"
	
# Install all system dependencies in one layer for all Browsers	
RUN yum update -y && \
    yum install -y \
        java-17-openjdk \
	    java-17-openjdk-devel \
	    wget tar gzip git unzip \
	    alsa-lib atk cairo cups-libs dbus-glib fontconfig freetype \
	    glib2 gtk3 libdrm libX11 libxcb libXcomposite libXcursor \
	    libXdamage libXext libXfixes libXi libxkbcommon libXrandr \
	    libXrender libXScrnSaver libxshmfence libXt libXtst \
	    mesa-libgbm nspr nss pango at-spi2-atk at-spi2-core expat \
	    libX11-xcb \
	    libicu libatomic libxslt libjpeg-turbo libwebp libsecret \
	    mesa-libEGL mesa-libGL libffi libevent&& \
	yum clean all && \
	rm -rf /var/cache/yum

# Install Maven
RUN cd /tmp && \
    wget https://archive.apache.org/dist/maven/maven-3/3.9.12/binaries/apache-maven-3.9.12-bin.tar.gz && \
    tar -xzf /tmp/apache-maven-3.9.12-bin.tar.gz -C /opt && \
    mv /opt/apache-maven-3.9.12 /opt/maven && \
    rm -f apache-maven-3.9.12-bin.tar.gz	
	

# Verify Maven version
RUN mvn --version

WORKDIR /app

# Copy pom.xml first
COPY pom.xml .

# Download Maven dependencies
RUN mvn dependency:go-offline -B || true

# Install Playwright browsers WITHOUT system dependencies (we already installed them!)
RUN mvn exec:java -e -Dexec.mainClass=com.microsoft.playwright.CLI -Dexec.args="install chromium"

# Verify browsers are installed
RUN mvn exec:java -e -Dexec.mainClass=com.microsoft.playwright.CLI -Dexec.args="--version" || true

# Copy source code
COPY src ./src

# Create test result directories
RUN mkdir -p /app/test-results/screenshots \
             /app/test-results/videos \
             /app/test-results/traces && \
    chmod -R 777 /app/test-results

RUN mkdir -p /ms-playwright  && cp -r /root/.cache/ms-playwright /ms-playwright

	
# Default command
CMD ["mvn", "test"]

#-------------------------
	
# Commands to build the image and run the container 
#Build Docker Image
#docker build -t <Docker_Image_Name> . 

#This way, the container writes directly into ./ms-playwright on your host from the container.
#docker run --rm -v $(pwd)/ms-playwright:/root/.cache/ms-playwright pw_jdk-mvn-chromium-cli:13feb1210pm mvn test -DTest=SimpleTest   

#Loginto the Contianer: 
#docker run -it --rm  <Docker_Image_Name> /bin/bash

#Run the docker contianer with SimpleTest Configured in the framework
#docker run --rm -v $(pwd):/workspace -w /workspace <Docker_Image_Name> mvn test -Dtest=SimpleTest
