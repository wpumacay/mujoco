#include <array>
#include <filesystem>
#include <iostream>
#include <string>

#include <fmt/base.h>
#include <fmt/format.h>

#include <mujoco/mujoco.h>

constexpr const char *XML_STRING = R"(
<mujoco model="empty-scene">
  <visual>
    <headlight diffuse="0.6 0.6 0.6" ambient="0.3 0.3 0.3" specular="0 0 0"/>
    <rgba haze="0.15 0.25 0.35 1"/>
    <global azimuth="120" elevation="-20"/>
  </visual>

  <asset>
    <texture type="skybox" builtin="gradient" rgb1="0.3 0.5 0.7" rgb2="0 0 0" width="512" height="3072"/>
    <texture name="SkyOakland" type="skybox" file="{0}/assets/SkyOakland.png" gridsize="2 4" gridlayout="LFRB.D.."/>
    <texture type="2d" name="groundplane" builtin="checker" mark="edge" rgb1="0.2 0.3 0.4" rgb2="0.1 0.2 0.3"
      markrgb="0.8 0.8 0.8" width="300" height="300"/>
    <material name="groundplane" texture="groundplane" texuniform="true" texrepeat="5 5" reflectance="0.2"/>
  </asset>

  <worldbody>
    <light pos="1 -1 1.5" dir="-1 1 -1" diffuse="0.5 0.5 0.5" directional="true"/>
    <geom name="floor" size="0 0 0.05" type="plane" material="groundplane"/>
  </worldbody>
</mujoco>
)";

constexpr const char *TEXTURE_SKYBOX_NAME = "SkyOakland";

auto main() -> int {
  auto xml_model_str = fmt::format(XML_STRING, "foo");
  fmt::print(xml_model_str);
  std::cout << std::endl;
  std::cout << std::endl;

  std::array<char, 1000> err;
  auto spec = mj_parseXMLString(XML_STRING, nullptr, err.data(), err.size());
  if (!spec) {
    std::cout << "There was an error while making a spec from given string"
              << std::endl;
    std::cout << err.data() << std::endl;
    return 1;
  }

  auto skybox_texture =
      mjs_asTexture(mjs_findElement(spec, mjOBJ_TEXTURE, TEXTURE_SKYBOX_NAME));
  if (skybox_texture) {
    std::cout << "gridlayout: " << skybox_texture->gridlayout << std::endl;
    std::cout << "gridsize: " << skybox_texture->gridsize << std::endl;
  }

  mj_deleteSpec(spec);

  return 0;
}
