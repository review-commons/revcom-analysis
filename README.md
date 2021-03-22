This repository provides the data and code to generate the analysis of the _Review Commons_ editorial and transfer pipeline. 


# Setup

Before running the notebook, setup your python virtual environment:

````
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
````

Launch the notebook

    jupyter notebook

Open the `code/analysis.ipynb` file and start running the notebook.

# Data

The data used for the analysis are availale in `data/` in an anonymized form.

# Results

The figures resulting from the analysis are available in the [`results/`](https://github.com/review-commons/revcom-analysis/tree/master/results) directory.

# Docker

Clone this repository:

    git clone https://github.com/review-commons/revcom-analysis.git
    cd revcom-analysis

Install Docker (https://docs.docker.com/) and build the docker container:

    docker build -t rc .

To run the notebook from the container:

    docker run --rm -v $PWD/data:/data -v $PWD/results:/results -v $PWD/code:/code -p 0.0.0.0:8888:8888 rc
    # Jupyter Notebook 6.2.0 is running at:
    # http://c4ee7b23542f:8888/?token=...
    # or http://127.0.0.1:8888/?token=...

Visit the `http://127.0.0.1:8888/?token=...` link.

**Important** edit the notebook to set `DATA_DIR = "/data"` and `IMG_DIR = "/results"` before running the notebook from within container!

The notebook can be further modified and changes will be saved locally.

To shutdown the notebook, type ctrl-C and confirm with 'y'.