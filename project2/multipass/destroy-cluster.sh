#!/bin/bash
multipass delete --purge worker1 worker2 worker3 worker4 
rm -f output.json
echo "Cluster destroyed!"
