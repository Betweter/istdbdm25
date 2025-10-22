
# IST Data Base and Data Mining Lab Repo

### The Relational models using PostgreSQL

#### Teaching Assistants: Mohamed Ragab and Fabiano Spiga

#### [Practice Session slides](https://drive.google.com/file/d/1_SfRoWH07lcdYxV_rVjM5KhcQ-V_4gIO/view?usp=sharing)

# Instructions 

- Create a new codespace
- run first ```docker compose build```
- in a new terminal, run ```docker compose pull``
- when both have terminated, run in either of the terminals, ```docker compose up -d```
- once run, you will see 3 links opening under the PORTS tab in visual studio
  - one on port 5432, one on 8080, and one in 8888

- click on the link on 8080 and choose a password for PgADMIN, I recommend ```postgres``
- add a new connection
  - name: postgres
  - host: postgres
  - port: 5432
  - password: postgres

- if anything happens to your containers during the practice, just run ```docker compose up``` again.

## Use GitHub Codespaces

Codespaces natively support Visual Studio (both remotely via browser or locally via ssh connection).

Follow [this](https://docs.github.com/en/codespaces/developing-in-a-codespace/creating-a-codespace-for-a-repository) guide to create the codespace for the repository.

The you can operate directly in visual studio.


## Local Installation 

Installing "Python", "Jupyter Notebook", and "PostgreSQL".


### Windows Users:

- Install Python(3+) and Jupyter Notebook (on windows):
    - [Python, Jupyter](https://medium.com/@kswalawage/install-python-and-jupyter-notebook-to-windows-10-64-bit-66db782e1d02)
    - **Recommended Option**: [Install Anaconda](https://www.datacamp.com/community/tutorials/installing-anaconda-windows)

- Install PostgreSQL on windows:
   - Please, [Download] (https://www.enterprisedb.com/downloads/postgres-postgresql-downloads) and Install PostgreSQL for all platforms
   - Follow this tutorial (https://www.postgresqltutorial.com/install-postgresql/) for more details (Windows installation).

### For Linux users:
- [For installing Anaconda on Linux](https://www.digitalocean.com/community/tutorials/how-to-install-anaconda-on-ubuntu-18-04-quickstart)
   - Then, you can execute the command $ jupyter notebook to launch Jupyter notebook on your Linux machine.
- If you want to install PostgreSQL on Linux:
   - [Tutorial](https://www.postgresqltutorial.com/install-postgresql-linux/)

### Docker users

Simply clone the repository and run

```docker-compose up``


The following docker compose file will build the notebook container which includes all the required dependencies.
Services are also exposed to the host network so you can connect to the via localhost

### WSL Users

## For Windows Users users

1) Change operating systems

2) if you cannot do that
3) create a file .wslconfig in the folder /Users/<UserProfile>
4) copy the following content in it
```
[wsl2]
# Cap the total RAM WSL2 can use across all distros.
# On an 8 GB machine, 4 GB is a safe ceiling for Docker work.
memory=4GB

# Limit vCPUs WSL2 can use (optional).
# If you have a 4-core/8-thread CPU, 4 here is reasonable.
processors=4

# Provide swap space for memory spikes (Docker builds, etc.).
# Keep this modest on an 8 GB host.
swap=4GB

# Optional: store the swap file somewhere with enough free space.
# Comment this out to use the default location.
# swapfile=C:\\wsl-swap.vhdx

# Keep localhost port forwarding (Windows <-> Linux) enabled.
localhostForwarding=true

```
5) reboot docker
