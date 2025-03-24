# BitBulldozersLab

**Bit Bulldozers Lab** - *Bluntly pushed bits, bytes &amp; pieces for HPC.*

This repository contains proof-of-concepts (PoCs) and examples related to High Performance Computing (HPC). These PoCs and examples fulfilled some purpose when they were created, but are, in general, unmaintained and comes without any claim of fitness for a particular purpose - use at you own risk and as you see fit!

## PoC / example structure

The PoCs and examples are organized into a flat namespace, i.e. each folder in this repository root is a PoC / example. The title of the PoC / example is used as the name of the folder. Each of those PoC / example folders contain all files related to that PoC / example, including a `README.md` file documenting the it.

### PoC / example README.md

The `README.md` file in each PoC / example folder contains at least the following:

* The title of the PoC / example
* A list of keywords, formatted on a single line as `- **Keywords:** MPI, AI, ...`
* The date that the PoC / example was last run, formatted on a single line as `- **Date:** YYYY-MM-DD`
* A description of the purpose of the PoC / example
* A description of how to run the PoC / example
* A summary of the main findings
* A list of known issues

## Simple keyword searches

The [GitHub search syntax](https://docs.github.com/en/search-github/github-code-search/understanding-github-code-search-syntax) allows one to search for PoCs / examples with specific listed keywords, e.g. the search query `repo:DeiC-HPC/BitBulldozersLab path:README.md /^Keywords.*(MPI|AI)/` should list all PoCs / examples related to MPI or AI.

### List of keywords

The following keywords are used in the PoCs / examples:

| Keyword         | Description                                                 |
| --------------- | ----------------------------------------------------------- |
| AI              | Artificial Intelligence                                     |
| cotainr         | The [cotainr](https://github.com/DeiC-HPC/cotainr) tool     |
| Guix            | The [Guix package manager](https://hpc.guix.info/) for HPC  |
| Jupyter         | Interactive computing using [Jupyter](https://jupyter.org/) |
| MPI             | Message Parsing Interface                                   |
| OOD             | [OpenOnDemand](https://openondemand.org/)                   |
| Pytorch         | The [Pytorch](https://pytorch.org/) AI framework            |
| Singularity     | Singularity containers                                      |

## Licensing Information

The content in this repository is licensed under the European Union Public License (EUPL) 1.2, unless otherwise mentioned in the specific file. See the [LICENSE file](https://github.com/DeiC-HPC/BitBulldozersLab/blob/main/LICENSE) for details about the EUPL 1.2 license.
