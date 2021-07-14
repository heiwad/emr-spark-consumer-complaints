# emr-spark-consumer-complaints
This is a demo that shows how to use features of EMR notebooks to process a data set with PySpark and Pandas.


The demo notebok requires an EMR cluster that has Spark, Livy, and JupyterEnterpriseGateway packages installed. It also requires that the cluster has been bootstrapped using nltk-bootstrap.sh

To automate this process launch-cluster.sh is provided.

To try the demo

1. Open AWS Cloud Shell
2. Git clone the repo in Cloud Shell
3. Run `sh ./launch-cluster.sh` in the Cloud Shell session to set up your environment.
4. Switch to the EMR Console and create an EMR notebook.
5. Attach the notebook to `Notebook cluster` and then open Jupyter to start the notebook session.
6. Upload cfpb-complaints.ipynb to your notebook session.
7. Open cfpb-complaints.ipynb and run the cells.

