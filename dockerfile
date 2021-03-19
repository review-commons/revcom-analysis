FROM python:3.7-buster

RUN pip install -U --no-cache-dir \
    kaleido==0.2.1 \
    nbformat==5.1.2 \
    notebook==6.2.0 \
    openpyxl==3.0.7 \
    pandas==1.2.3 \
    plotly==4.14.3 \
    xlrd==2.0.1

COPY . /app
WORKDIR /app/code
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]