#!/bin/bash

echo "192.168.56.10	testing" | sudo tee -a /etc/hosts
echo "192.168.56.20     produccion" | sudo tee -a /etc/hosts
