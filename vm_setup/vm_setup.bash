#amazon linux 2023 is based on a fedora distro so commands are based on that 
export PYTHON_VERSION="3.9.16"
export AIRFLOW_VERSION="2.8.1"
export PROJECT_NAME="crypto_data"
export VENV_NAME="airflow_env"

yes | sudo dnf update #update the system
yes | sudo dnf install python3-pip #install python and git, [ yes | ] answers any prompt to the command with yes 
yes | sudo dnf install git

git clone https://github.com/caue-paiva/airflow_project -b vm_branch
cd airflow_project/
cd vm_setup/
export MAIN_WORK_DIR="$(pwd)" #main dir we will use for the project, named vm_setup

python3 -m venv ${VENV_NAME}
source /${VENV_NAME}/bin/activate #we will need to activate this env to use the airflowctl command
pip install -r _requirements.txt
export VENV_PATH=${MAIN_WORK_DIR}/${VENV_NAME}

airflowctl init ${PROJECT_NAME} --airflow-version ${AIRFLOW_VERSION} --python-version ${PYTHON_VERSION} ----venv_path ${VENV_PATH} #inits the airflowctl project 
cd ${PROJECT_NAME}
airflowctl build #builds project 
cd ..
airflowctl start ${PROJECT_NAME} --background 

cd ${PROJECT_NAME}/dags/ 
mkdir include #creating folder for python code not used by the dags
cd ..
cd ..

mv binance_api.py crypto_data_etl.py ${PROJECT_NAME}/dags/include/  #move auxiliary python files to include folder
mv crypto_data.py ${PROJECT_NAME}/dags/ #move main dag file to dag folder
mv variables_setup.json ${PROJECT_NAME}/  #moves json file that setups the env variables to inside the project
cd ${PROJECT_NAME}
airflowctl airflow variables import variables_setup.json #setting up airflow env variables

#13140 hours is equivalent to 1,5 years

#--connections

# 1} export all connections to a file using airflowctl airflow connections export ${file}, needs to be inside airflowctl project folder

# 2} Get the specific AWS connection {DO NOT SHARE IT ON GITHUB} and make a json file only with it {or keep the others ununsed connections}

# 3} Import the connections file using airflowctl airflow connections import ${file}
