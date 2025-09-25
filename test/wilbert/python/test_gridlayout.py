from pathlib import Path

import mujoco as mj

CURRENT_DIR = Path(__file__).parent
ASSETS_DIR = CURRENT_DIR.parent / "assets"

SKYBOX_NAME = "SkyOakland"

XML_STRING = """
<mujoco model="empty-scene">
  <visual>
    <headlight diffuse="0.6 0.6 0.6" ambient="0.3 0.3 0.3" specular="0 0 0"/>
    <rgba haze="0.15 0.25 0.35 1"/>
    <global azimuth="120" elevation="-20"/>
  </visual>

  <asset>
    <texture type="skybox" builtin="gradient" rgb1="0.3 0.5 0.7" rgb2="0 0 0" width="512" height="3072"/>
    <texture name="SkyOakland" type="skybox" file="{texname}" gridsize="2 4" gridlayout="LFRB.D.."/>
    <texture type="2d" name="groundplane" builtin="checker" mark="edge" rgb1="0.2 0.3 0.4" rgb2="0.1 0.2 0.3"
      markrgb="0.8 0.8 0.8" width="300" height="300"/>
    <material name="groundplane" texture="groundplane" texuniform="true" texrepeat="5 5" reflectance="0.2"/>
  </asset>

  <worldbody>
    <light pos="1 -1 1.5" dir="-1 1 -1" diffuse="0.5 0.5 0.5" directional="true"/>
    <geom name="floor" size="0 0 0.05" type="plane" material="groundplane"/>
  </worldbody>
</mujoco>
"""


def main() -> int:
    skybox_texture_path = ASSETS_DIR / f"{SKYBOX_NAME}.png"
    model_str = XML_STRING.format(texname=skybox_texture_path.as_posix())

    spec: mj.MjSpec = mj.MjSpec.from_string(model_str)
    print(f"gridlayout: {spec.texture(SKYBOX_NAME).gridlayout}")
    print(f"gridsize: {spec.texture(SKYBOX_NAME).gridsize}")

    _ = spec.compile()
    test_model_path = CURRENT_DIR / "test_model.xml"
    with open(test_model_path, "w") as fhandle:
        fhandle.write(spec.to_xml())

    try:
        _ = mj.MjModel.from_xml_path(test_model_path.as_posix())
    except Exception as e:
        print(f"Got error while opening the saved model: {e}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
