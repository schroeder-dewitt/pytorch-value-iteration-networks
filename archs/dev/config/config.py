from os.path import join

def get_config():
    home_path = "/root/cmap"
    cfg = dict(
        venv_path=join(home_path, ".venv"),
        exp_path=join(home_path, "exp"),
        lib_path=join(home_path, "lib"),
        data_path=join(home_path, "data"),
        log_path=join(home_path, "log"),
        tmp_path=join(home_path, "tmp"),
        gpu_id=0
    )

    return cfg