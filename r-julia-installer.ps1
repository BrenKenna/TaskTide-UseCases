# Allow script execution
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force


# Install Scoop
irm get.scoop.sh -outfile 'install.ps1'
.\install.ps1 -RunAsAdmin


# Configure download sources
scoop bucket add extras
scoop bucket add versions
scoop bucket add r https://github.com/cderv/r-bucket.git


# Install Julia & R
scoop install main/julia
scoop install r
scoop install rstudio


# Configure spark installation
$SparkVersion = "3.5.1"
$SparkDownloadUrl = "https://dlcdn.apache.org/spark/spark-$SparkVersion/spark-$SparkVersion-bin-hadoop3.tgz"
$SparkInstallDir = "$env:USERPROFILE\scoop\apps\spark\current"
if (-not (Test-Path $SparkInstallDir)) { New-Item -ItemType Directory -Path $SparkInstallDir -Force }


# Fetch and unpack Spark
Invoke-WebRequest -Uri $SparkDownloadUrl -OutFile "$env:TEMP\spark.tgz"
tar -xzf "$env:TEMP\spark.tgz" -C "$SparkInstallDir" --strip-components 1
Remove-Item "$env:TEMP\spark.tgz"


# Set its environment variables
[System.Environment]::SetEnvironmentVariable("SPARK_HOME", $SparkInstallDir, "User")
$env:PATH += ";$SparkInstallDir\bin"


# Download RAPIDS Accelerator JAR from Maven-Central
$RAPIDSVersion = "25.08.0"
$ScalaVersion = "2.12"
$CUDAVersion = "cuda11"
$RAPIDSJarUrl = "https://repo1.maven.org/maven2/com/nvidia/rapids-4-spark_$ScalaVersion/$RAPIDSVersion/rapids-4-spark_$ScalaVersion-$RAPIDSVersion-$CUDAVersion.jar"
$RAPIDSJarPath = "$SparkInstallDir\jars\rapids-4-spark_$ScalaVersion-$RAPIDSVersion-$CUDAVersion.jar"
Invoke-WebRequest -Uri $RAPIDSJarUrl -OutFile $RAPIDSJarPath