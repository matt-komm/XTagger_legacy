./Training/AnacondaEnv/setupEnv_cpuonly.sh testenv
source Training/AnacondaEnv/env.sh
python -c "import tensorflow as tf"
python -c "import keras"
