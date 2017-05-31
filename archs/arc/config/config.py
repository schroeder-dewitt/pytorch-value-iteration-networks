from os.path import join

def get_config():
    home_path = "/home/engs-tvg-jvlmdr/exet2727/"
    data_path = "/data/engs-tvg-jvlmdr/exet2727/"
    cfg = dict(
        venv_path=join(home_path, ".venv"),
        experiment_root_path=join(home_path, "exp"),
        lib_path=join(home_path, "lib"),
        data_path=data_path
    )
    return cfg