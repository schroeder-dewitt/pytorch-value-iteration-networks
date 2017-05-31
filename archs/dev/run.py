"""
To be run locally inside Ubuntu Docker environment
"""

import argparse
import os
import time
import yaml

#import sys
#sys.path.append("/home/cs/projects/cmap")

import sys
sys.path.insert(0,'/home/cs/projects/cmap')

def main(*args, **kwargs):
    """
    To be executed on host octavia
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("setup", help="specify experimental setup name")
    parser.add_argument("--tag", help="specify setup tag")
    argse = parser.parse_args()
    setup = argse.setup
    tag = argse.tag

    if tag is None:
        tag = str(time.time())

    #######################################
    # Set up local folder infrastructure
    #######################################

    from archs.octavia.config.config import get_config as octavia_get_config
    octavia_cfg = octavia_get_config()

    output_local_path = "{}/{}/{}".format(octavia_cfg["experiment_root_path"], setup, tag)

    results_local_path = os.path.join(output_local_path, "results")
    assert not os.path.exists(results_local_path), \
                                "FATAL ERROR: Experiment results path already exists - choose a different tag or leave empty for timestamp!"
    os.makedirs(results_local_path)

    logs_local_path = os.path.join(output_local_path, "logs")
    assert not os.path.exists(logs_local_path), \
                                "FATAL ERROR: Experiment logs path already exists - choose a different tag or leave empty for timestamp!"
    os.makedirs(logs_local_path)

    tmp_local_path = os.path.join(output_local_path, "tmp")
    assert not os.path.exists(tmp_local_path), \
                                "FATAL ERROR: Experiment tmp path already exists - choose a different tag or leave empty for timestamp!"
    os.makedirs(tmp_local_path)

    config_local_path = os.path.join(output_local_path, "config")
    assert not os.path.exists(config_local_path), \
                                "FATAL ERROR: Experiment config path already exists - choose a different tag or leave empty for timestamp!"
    os.makedirs(config_local_path)

    #######################################
    # Set up remote folder infrastructure
    #######################################

    script_local_path = os.path.realpath(__file__)
    repo_root_local_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "..", "..")
    src_local_path = os.path.join(repo_root_local_path, "src")
    key_local_path = os.path.join(repo_root_local_path, "install", "ssh-keys", "id_rsa")
    data_local_path = os.path.join(os.path.dirname(script_local_path), "..", "..", "data")

    data_resources = ["bhatti-dqn-pretrain",
                      "vizdoom"]

    libs_local_path = os.path.join(repo_root_local_path, "data")
    module = [dict(
                    name = "python/3.5",
                    paths = ["pythonpath", "path"]
                )]

    print(key_local_path)

    from archs.dev.config.config import get_config as dev_get_config
    dev_cfg = dev_get_config()

    venv_remote_path = dev_cfg["venv_path"]
    exp_root_remote_path = os.path.join(dev_cfg["exp_path"], "cmap", setup, tag)
    lib_remote_path = dev_cfg["lib_path"]
    data_remote_path = dev_cfg["data_path"]

    from fabric.api import hosts, env, run, put
    from fabric.contrib.files import exists
    from fabric.tasks import execute

    #env.hosts = ['arcus-b.arc.ox.ac.uk']
    #env.user = 'exet2727'
    #env.key_filename = key_local_path
    env.password = "source"

    def setup_ssh():

        print("Create remote experiment folder...")
        run("mkdir -p {}".format(exp_root_remote_path))

        print("Copy source to remote machine...")
        print("Compressing source folder...")
        src_archive_name = "{}.tar.gz".format("src")
        src_archive_local_path = "{}/{}".format(tmp_local_path, src_archive_name)
        os.system("tar -zcvf {} {}".format(src_archive_local_path, src_local_path))
        print("Now uploading compressed source folder...")
        put(src_archive_local_path, exp_root_remote_path)
        print("tar -zxvf {}{} ".format(exp_root_remote_path, src_archive_name))
        # quit()
        run("cd {} && tar -zxvf {}".format(exp_root_remote_path, src_archive_name, exp_root_remote_path))
        print("source upload is done!")

        # copy data to remote (into central repo)
        # TODO: add some kind of checksum, for now: have to change dirname for each different folder
        for dr in data_resources:
            if not exists(os.path.join(data_remote_path, dr+"/")):
                print("Uploading data {} ...".format(dr))
                print("LOCAL DATA PATH: {}".format(os.path.join(data_local_path, dr)))
                run("mkdir -p {}".format(os.path.join(data_remote_path, dr+"/")))
                put(os.path.join(data_local_path, dr+"/"), os.path.join(data_remote_path, dr+"/"))
                pass

        # copy libraries to remote - probably not the right way to do it!
        # for lib in libs:
        #    put(libs_local_path, os.path.join(exp_root_remote_path, "lib"))
        #

        # set up virtual env remotely!
        # TODO later

        # # render setup.yml # contains information about architecture-specific paths
        arch_cfg = dict()
        arch_cfg["exp_path"] = exp_root_remote_path
        arch_cfg["config_path"] = os.path.join(exp_root_remote_path, "config")
        arch_cfg["log_path"] = os.path.join(exp_root_remote_path, "log")
        arch_cfg["data_path"] = data_remote_path
        arch_cfg["lib_path"] = lib_remote_path
        arch_cfg["tmp_path"] = os.path.join(exp_root_remote_path, "tmp")

        # set up visdom server if not running already

        import socket; s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            s.bind(("127.0.0.1", 8097))
            import subprocess
            subprocess.Popen(["python","-m","visdom.server"])
        except socket.error as e:
            if e.errno == 98:
                print("Port is already in use - visdom already running!")
            else:
                # something else raised the socket.error exception
                print(e)
        s.close()


        arch_cfg["visdom_options"] = dict( server = "octavia.robots.ox.ac.uk",
                                           port = 8097)

        with open(os.path.join(config_local_path, "arch.yaml"), 'w') as f:
            yaml.dump(arch_cfg, f)

        print("Now putting arch config up...")
        run("mkdir -p {}".format(arch_cfg["config_path"]))
        put(os.path.join(config_local_path, "arch.yaml"), os.path.join(arch_cfg["config_path"], "arch.yaml"))

        # render submit.sh
        venv_path = ""
        set_env_variables = ""
        job_name = "{}_{}".format(arch_cfg, tag)
        load_modules = ""
        run_application = "python3 {}/setups/{}.py {} {}".format(os.path.join(exp_root_remote_path, "src"),
                                                        setup,
                                                        os.path.join(arch_cfg["config_path"], "arch.yaml"),
                                                        os.path.join(arch_cfg["config_path"], "config.yaml"))
        venv_name = "slamdoom"

        import jinja2
        with open(os.path.join(tmp_local_path, "submit.sh"), "w") as f:
            template_output = jinja2.Environment(
                loader=jinja2.FileSystemLoader(os.path.join(os.path.dirname(script_local_path), "templates"))) \
                .get_template("submit.template.sh") \
                .render(partition="gpu",
                        venv_path="~/.venv",
                        job_name=job_name,
                        set_env_variables=set_env_variables,
                        load_modules=load_modules,
                        run_application=run_application,
                        venv_name=venv_name,
                        lib_dir="~/cmap/lib",
                        exp_dir=exp_root_remote_path)
            f.write(template_output)

        print("Now putting submit.sh up...")
        put(os.path.join(tmp_local_path, "submit.sh"), os.path.join(exp_root_remote_path, "submit.sh"))
        run("chmod +x {}".format(os.path.join(exp_root_remote_path, "submit.sh")))

        # generate setup.yml
        setup_module = __import__("src.setups.configs.{}".format(setup), fromlist='.')
        #setup_module.write(results_root_path, logs_root_path)
        setup_cfg = setup_module.get_config()
        setup_cfg["name"] = setup
        setup_cfg["tag"] = tag
        with open(os.path.join(config_local_path, "config.yaml"), "w") as f:
            f.write(yaml.dump(setup_cfg))
        # run("mkdir -p {}".format(, ))
        put(os.path.join(config_local_path, "config.yaml"), os.path.join(arch_cfg["config_path"], "config.yaml"))


        print("Create remote tmp folder...")
        run("mkdir -p {}".format(arch_cfg["tmp_path"]))

        # run the setup
        print("Now running setup...")
        run("{}".format(os.path.join(exp_root_remote_path, "submit.sh")))

    execute(setup_ssh, hosts=["root@localhost"])

    # launch remote experiment

    pass

if __name__ == "__main__":
    main()