from pathlib import Path

import mujoco as mj

CURRENT_DIR = Path(__file__).parent


XML_STRING = """
<mujoco model="empty-scene">
  <visual>
    <headlight diffuse="0.6 0.6 0.6" ambient="0.3 0.3 0.3" specular="0 0 0"/>
    <rgba haze="0.15 0.25 0.35 1"/>
    <global azimuth="120" elevation="-20"/>
  </visual>

  <asset>
    <texture type="skybox" builtin="gradient" rgb1="0.3 0.5 0.7" rgb2="0 0 0" width="512" height="3072"/>
    <texture name="SkyOakland" type="skybox" file="{folder}/assets/SkyOakland.png" gridsize="2 4" gridlayout="LFRB.D.."/>
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
    assets_rel_path = CURRENT_DIR.relative_to(Path.cwd())
    model_str = XML_STRING.format(folder=assets_rel_path.as_posix())

    spec: mj.MjSpec = mj.MjSpec.from_string(model_str)
    spec.texture("SkyOakland").gridlayout = mj._specs.MjCharVec("LFRB.D..", len("LFRB.D.."))

    breakpoint()

    _ = spec.compile()
    with open(CURRENT_DIR / "test_model.xml", "w") as fhandle:
        fhandle.write(spec.to_xml())

    breakpoint()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
