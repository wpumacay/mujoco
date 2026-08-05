from dataclasses import dataclass
from pathlib import Path

import mujoco as mj
import numpy as np
import tyro
from mujoco.rendering.classic import gl_context
from PIL import Image

GLContext = gl_context.GLContext if hasattr(gl_context, 'GLContext') else None

@dataclass
class Args:
    filepath: Path

    width: int = 640
    height: int = 480


def main() -> int:
    args = tyro.cli(Args)

    if not args.filepath.is_file():
        return 1

    # breakpoint()

    model = mj.MjModel.from_xml_path(args.filepath.as_posix())
    data = mj.MjData(model)

    mj.mj_resetData(model, data)
    mj.mj_forward(model, data)

    scene = mj.MjvScene(model=model, maxgeom=4000)
    option = mj.MjvOption()
    viewport = mj.MjrRect(0, 0, args.width, args.height)

    gl_ctx = None
    if GLContext is not None:
        gl_ctx = GLContext(args.width, args.height)
    if gl_ctx is not None:
        gl_ctx.make_current()

    context = mj.MjrContext(model, mj.mjtFontScale.mjFONTSCALE_150)
    mj.mjr_setBuffer(mj.mjtFramebuffer.mjFB_OFFSCREEN, context)

    camera = mj.MjvCamera()
    camera.fixedcamid = -1
    camera.type = mj.mjtCamera.mjCAMERA_FREE
    mj.mjv_defaultFreeCamera(model, camera)

    mj.mjv_updateScene(model, data, option, None, camera, mj.mjtCatBit.mjCAT_ALL, scene)
    mj.mjr_render(viewport, scene, context)

    out = np.empty((args.height, args.width, 3), dtype=np.uint8)
    mj.mjr_readPixels(out, None, viewport, context)

    image = Image.fromarray(out)
    image.save("img_render.jpg")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
