# Bioinformatics Challenge Project - ELM

This repository contains all of the work from the Boston University Bioinformatics Challenge Project (2024-2025) for the ELM group.

**---Advisor-----------------------**\
[Dr. Jennifer Bhatnagar](https://microbesatbu.wordpress.com/)\
*-----------------------------------*

**---Project Lead------------------**\
Kathryn Atherton\
*-----------------------------------*

**---Members-----------------------**\
Emily Kim (ekim7@bu.edu)\
Luke Berger (lukeberg@bu.edu)\
Medhini Rachamallu (medhinir@bu.edu)\
*-----------------------------------*

**---Collaborators-----------------**\
[Dr. Brandon Matheny](https://mathenylab.utk.edu/Site/Home.html)\
Dr. Chance Noffsinger\
*-----------------------------------*

Written by Emily Kim, Luke Berger, and Medhini Rachamallu\
Updated May 15, 2025

Note: parts of the document still need to be filled out. see "UNFINISHED" in document.

---

**Main content**

- [Repository structure](#repository-structure)
- [Walkthrough](#walkthrough)

**Other methods**

- [Reference tree creation](#reference-tree-creation)
- [Backbone creation](#backbone-creation)
- [ITS2 structure](#its2-structure)

**Relevant links**

- [Abstract][1]
- [Poster][2]
- [Talk][3]

[1]: https://docs.google.com/document/d/1dt9sazbV2kcsU81y4vKrnDSRtkHYI_G2e9jZpZs_FQQ/edit?tab=t.0
[2]: https://docs.google.com/presentation/d/1v67D7gKjYA1cpKDt-7imFqFJlTpr-EKQ/edit?slide=id.p1#slide=id.p1
[3]: https://docs.google.com/presentation/d/1QJFQN4U_1VD5zAhaIDCn_6W42D9rSfmG/edit?slide=id.p1#slide=id.p1

---

# Repository structure

*: directories

- *`reference_trees`
    - contains all tree files for references
    - `tip_pruning.Rmd`: code to prune reference trees and create backbones
    - *`database_information`: files needed to do tip pruning
    - *`taxonomy`: files needed to get taxonomy information for JGI/Li trees
    - *`unmodified_references`: all original tree files

UNFINISHED
---

# Walkthrough

UNFINISHED: add luke + medhini stuff

### #. Get Nye score
The [Nye score][100] is a topology-based, similarity scoring metric. To get a similarity score between two trees, use the [treeDistances.R][101] script. Instructions for use are available in the script.

[100]: https://academic.oup.com/bioinformatics/article/22/1/117/217975
[101]: https://github.com/ehk-kim/MMG_ELM/tree/main/reference_trees/treeDistances.R

```bash
Rscript treeDistances.R referenceTree inputTree outputFile

# We used the Looney et al. (2018) Russulaceae family tree for our reference
```

---

# Reference tree creation

Custom editing of the reference trees may be necessary for a variety of reasons.

| Modification | Reason |
| ----------- | ----------- |
| Drop species with unspecified genus or species name | Assume we are less confident in their placements than those of specified genus or species |
| Rename tips to follow `Genus_species` | Standardize naming across databases |
| In the case of duplicate species: keep the most ancestral | We want an "average" of strains for comparison purposes |

Below are the reasons we edited the following trees and methods involved. See [`tip_pruning.Rmd`][1000] for code.

[1000]: https://github.com/ehk-kim/MMG_ELM/blob/main/reference_trees/tip_pruning.Rmd

### [`JGI.nwk`](https://github.com/ehk-kim/MMG_ELM/blob/main/reference_trees/JGI.nwk)

- [x] Drop unspecified genera/species
- [x] Rename tips to `Genus_species`
- [x] Remove duplicates

**Methods**

1. Get all tips
2. Convert all JGI portal names to `Genus_species`
3. Remove names with `sp.`, `.cf`, numbers, and unconverted JGI portal names

### [`Lietal_2021.nwk`](https://github.com/ehk-kim/MMG_ELM/blob/main/reference_trees/Lietal_2021.nwk)

- [x] Drop unspecified genera/species
- [x] Rename tips to `Genus_species`
- [x] Remove duplicates

**Methods**

1. Get all tips
2. Remove names with `sp.`, `.cf` and numbers

### [`Looneyetal_2018.nwk`](https://github.com/ehk-kim/MMG_ELM/blob/main/reference_trees/Looneyetal_2018.nwk)

- [ ] Drop unspecified genera/species
- [ ] Rename tips to `Genus_species`
- [ ] Remove duplicates

No editing was needed. However, if tips are dropped in Nye score comparisons, take a look at the tip names to ensure that all of them are the same.

---

# Backbone creation

For code, see [`tip_pruning.Rmd`][1000]. 

### JGI/Li et al.

We did not create backbones for JGI/Li et al. 2021 but we have the code and files to do so.

Necessary files can be found in [`reference_trees/taxonomy`][200]. Li taxonomy data was pulled from [Li et al. 2021][201] Supplemental Data S1.

[200]: https://github.com/ehk-kim/MMG_ELM/tree/main/reference_trees/taxonomy
[201]: https://www.sciencedirect.com/science/article/pii/S0960982221001391?via%3Dihub#app2

### Looney et al.

1. Drop all tips except for 1 per genus. It doesn't matter which one you choose.
2. Save as the backbone.
3. Rename the species per genus to "genus_genusName"
4. Replace the genus_genusName with the genus-level trees.
---

# ITS2 structure

UNFINISHED: add 2f2f incorporating its2 structure stuff here