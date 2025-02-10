Overview
Úa-FESOM is a coupled ice sheet-ocean model designed to improve predictions of the Antarctic Ice Sheet's evolution over centennial timescales. The model integrates:

Úa: A finite element ice sheet model.
FESOM-1.4: A Finite Element Sea Ice Ocean Model.
By leveraging horizontally unstructured grids in both components, Úa-FESOM enables high-resolution simulations of key ice-ocean interactions while maintaining computational feasibility.

Key Features
✅ Resolves critical ice-ocean interactions near grounding lines and pinning points.
✅ Uses depth-dependent vertical coordinates for ocean modeling.
✅ Verified with the Marine Ice Sheet--Ocean Model Intercomparison Project (MISOMIP).
✅ Demonstrated retreat behavior of Pine Island Glacier in a 39-year hindcast (1979-2018).

Applications
🔹 Investigating ice-ocean interactions beneath small Antarctic ice shelves.
🔹 Improving predictions of ice sheet evolution under climate change.
🔹 Enhancing global ocean-Antarctic Ice Sheet coupling in climate models.

Funding & Acknowledgements
We thank the following individuals and institutions for their contributions:

👩‍💻 Code Contributions & Discussions: Verena Haid, Emily Hill, Claudia Wekerle.
🖥 Computing Support: Wolfgang Cohrs, Natalja Rakowsky, Malte Thoma, Sven Harig (AWI).
💻 HPC Resources: Provided by the Nationales Hochleistungsrechnen (NHR) alliance under project hbk00097.
🔬 Funding:

Supported by PROTECT, funded through the European Union’s Horizon 2020 programme (Grant No. 869304, PROTECT contribution No. 138).
JDR was supported by a UKRI Future Leaders Fellowship (Grant No. MR/W011816/1).
Main Developers
👨‍💻 Ole Richter & Ralph Timmermann (lead developers)
🛠 Contributions from Jan De Rydt & Hilmar Gudmundsson

Getting Started
To use Úa-FESOM, follow these steps:

Clone the repository:
sh
Copy
Edit
git clone https://github.com/your-repo/Ua-FESOM.git
cd Ua-FESOM
Installation (dependencies and setup instructions).
Running Simulations (basic usage examples).
Citing Úa-FESOM
If you use this model in your research, please cite the corresponding paper:

📄 [Paper Title]
Author List
DOI: 10.XXXX/zenodo.XXXXX

License
This project is licensed under the MIT License. See LICENSE for details.

# Mr. Timms couples Ua and FESOM 1.4
based on RAnGO from Ralph Timmermann
![Alt text](meshTotal.png)
