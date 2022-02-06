module ShadowMapping exposing (main)

import Browser
import Browser.Events
import Html exposing (Html)
import Html.Attributes exposing (height, style, width)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Vector4 exposing (Vec4)
import WebGL exposing (FrameBuffer, Mesh, Shader)
import WebGL.Texture exposing (Texture)


main : Program () Float Float
main =
    Browser.document
        { init = always ( 0, Cmd.none )
        , view = \model -> { title = "ShadowMapping", body = [ view model ] }
        , update = \dt theta -> ( theta + dt / 1000, Cmd.none )
        , subscriptions = \_ -> Browser.Events.onAnimationFrameDelta Basics.identity
        }


view : Float -> Html Float
view theta =
    let
        lightUniforms : { perspective : Mat4, camera : Mat4 }
        lightUniforms =
            { perspective = Mat4.makeOrtho -7 7 -7 7 -7 50
            , camera = Mat4.makeLookAt (vec3 (sin theta) 1 (-1 * cos theta)) (vec3 0 0 0) (vec3 0 1 0)
            }

        frameBuffer =
            WebGL.frameBuffer ( 1024, 1024 )
                (WebGL.entity
                    lightVertexShader
                    lightFragmentShader
                    planeMesh
                    lightUniforms
                    :: chair
                        lightVertexShader
                        lightFragmentShader
                        lightUniforms
                        theta
                )
    in
    WebGL.toHtmlWithFrameBuffers
        [ frameBuffer ]
        [ WebGL.alpha True, WebGL.antialias, WebGL.depth 1 ]
        [ width 600
        , height 600
        , style "display" "block"
        ]
        (\textures ->
            case textures of
                lightMap :: _ ->
                    WebGL.entity
                        vertexShader
                        fragmentShader
                        planeMesh
                        (uniforms theta lightMap)
                        :: chair vertexShader
                            fragmentShader
                            (uniforms theta lightMap)
                            theta

                _ ->
                    []
        )


chair vertexShader_ fragmentShader_ uniforms_ theta =
    [ WebGL.entity
        vertexShader_
        fragmentShader_
        (cubeMeshM
            (Mat4.makeTranslate3 1 -1 1
                |> Mat4.scale3 0.2 1 0.2
            )
        )
        uniforms_
    , WebGL.entity
        vertexShader_
        fragmentShader_
        (cubeMeshM
            (Mat4.makeTranslate3 -1 -1 1
                |> Mat4.scale3 0.2 1 0.2
            )
        )
        uniforms_
    , WebGL.entity
        vertexShader_
        fragmentShader_
        (cubeMeshM
            (Mat4.makeTranslate3 1 0 -1
                |> Mat4.scale3 0.2 2 0.2
            )
        )
        uniforms_
    , WebGL.entity
        vertexShader_
        fragmentShader_
        (cubeMeshM
            (Mat4.makeTranslate3 -1 0 -1
                |> Mat4.scale3 0.2 2 0.2
            )
        )
        uniforms_
    , WebGL.entity
        vertexShader_
        fragmentShader_
        (cubeMeshM
            (Mat4.makeTranslate3 0 0 0
                |> Mat4.scale3 1.2 0.2 1.2
            )
        )
        uniforms_
    , WebGL.entity
        vertexShader_
        fragmentShader_
        (cubeMeshM
            (Mat4.makeTranslate3 0 2 -1
                |> Mat4.scale3 1.2 0.2 0.2
            )
        )
        uniforms_
    ]


type alias Color =
    { red : Float, green : Float, blue : Float }


colors =
    { grey = Color (211 / 255) (215 / 255) (207 / 255)
    , green = Color (115 / 255) (210 / 255) (22 / 255)
    , blue = Color (52 / 255) (101 / 255) (164 / 255)
    , yellow = Color (237 / 255) (212 / 255) (0 / 255)
    , red = Color (204 / 255) (0 / 255) (0 / 255)
    , purple = Color (117 / 255) (80 / 255) (123 / 255)
    , orange = Color (245 / 255) (121 / 255) (0 / 255)
    }


type alias Uniforms =
    { perspective : Mat4
    , camera : Mat4
    , lightMViewMatrix : Mat4
    , lightProjectionMatrix : Mat4
    , texture : Texture
    }


uniforms : Float -> Texture -> Uniforms
uniforms theta texture =
    let
        lightUniforms =
            { perspective = Mat4.makeOrtho -7 7 -7 7 -7 50
            , camera = Mat4.makeLookAt (vec3 (sin theta) 1 (-1 * cos theta)) (vec3 0 0 0) (vec3 0 1 0)
            }
    in
    { perspective = Mat4.makePerspective (180 / 3) 1 0.01 100
    , camera = Mat4.makeLookAt (vec3 5 10 10) (vec3 0 0 0) (vec3 0 1 0)
    , lightMViewMatrix = lightUniforms.camera
    , lightProjectionMatrix = lightUniforms.perspective
    , texture = texture
    }


type alias LightUniforms =
    { perspective : Mat4
    , camera : Mat4
    }



-- Mesh


type alias Vertex =
    { color : Vec3
    , position : Vec3
    }


planeMesh : Mesh Vertex
planeMesh =
    let
        lb =
            vec3 -5 -2 5

        rb =
            vec3 5 -2 5

        rt =
            vec3 5 -2 -5

        lt =
            vec3 -5 -2 -5
    in
    face colors.grey rb rt lt lb
        |> WebGL.triangles


cubeMeshM : Mat4 -> Mesh Vertex
cubeMeshM m =
    cubeMeshTrM m (vec3 0 0 0)


cubeMeshTrM : Mat4 -> Vec3 -> Mesh Vertex
cubeMeshTrM m t =
    let
        rft =
            vec3 1 1 1

        lft =
            vec3 -1 1 1

        lbt =
            vec3 -1 -1 1

        rbt =
            vec3 1 -1 1

        rbb =
            vec3 1 -1 -1

        rfb =
            vec3 1 1 -1

        lfb =
            vec3 -1 1 -1

        lbb =
            vec3 -1 -1 -1
    in
    [ face colors.green rft rfb rbb rbt
    , face colors.blue rft rfb lfb lft
    , face colors.yellow rft lft lbt rbt
    , face colors.red rfb lfb lbb rbb
    , face colors.purple lft lfb lbb lbt
    , face colors.orange rbt rbb lbb lbt
    ]
        |> List.concat
        |> List.map
            (\( v1, v2, v3 ) ->
                ( { v1 | position = v1.position |> Vec3.add t |> Mat4.transform m }
                , { v2 | position = v2.position |> Vec3.add t |> Mat4.transform m }
                , { v3 | position = v3.position |> Vec3.add t |> Mat4.transform m }
                )
            )
        |> WebGL.triangles


face : Color -> Vec3 -> Vec3 -> Vec3 -> Vec3 -> List ( Vertex, Vertex, Vertex )
face color a b c d =
    let
        vertex position =
            Vertex (vec3 color.red color.green color.blue) position
    in
    [ ( vertex a, vertex b, vertex c )
    , ( vertex c, vertex d, vertex a )
    ]



-- Shaders


vertexShader : Shader Vertex Uniforms { vcolor : Vec3, shadowPos : Vec4 }
vertexShader =
    [glsl|

        attribute vec3 position;
        attribute vec3 color;
        uniform mat4 perspective;
        uniform mat4 camera;
        varying vec3 vcolor;

        //attribute vec3 aVertexPosition;
        //uniform mat4 uPMatrix;
        //uniform mat4 uMVMatrix;
        uniform mat4 lightMViewMatrix;
        uniform mat4 lightProjectionMatrix;
        // Used to normalize our coordinates from clip space to (0 - 1)
        // so that we can access the corresponding point in our depth color texture
        const mat4 texUnitConverter = mat4(0.5, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 0.5, 0.5, 0.5, 1.0);
        //varying vec2 vDepthUv;
        varying vec4 shadowPos;

        void main (void) {
          gl_Position = perspective * camera * vec4(position, 1.0);
          vcolor = color;
          shadowPos = texUnitConverter * lightProjectionMatrix * lightMViewMatrix * vec4(position, 1.0);
        }

    |]


fragmentShader : Shader {} Uniforms { vcolor : Vec3, shadowPos : Vec4 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec3 vcolor;
        varying vec4 shadowPos;
        uniform sampler2D texture;
        //uniform vec3 uColor;
        float decodeFloat (vec4 color) {
          const vec4 bitShift = vec4(
            1.0 / (256.0 * 256.0 * 256.0),
            1.0 / (256.0 * 256.0),
            1.0 / 256.0,
            1
          );
          return dot(color, bitShift);
        }
        void main(void) {
          vec3 fragmentDepth = shadowPos.xyz;
          float shadowAcneRemover = 0.007;
          fragmentDepth.z -= shadowAcneRemover;
          float texelSize = 1.0 / 1024.0;
          float amountInLight = 0.0;
          for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
              float texelDepth = decodeFloat(texture2D(texture, fragmentDepth.xy + vec2(x, y) * texelSize));
              if (fragmentDepth.z < texelDepth) {
                amountInLight += 1.0;
              }
            }
          }
          amountInLight /= 9.0;

          gl_FragColor = vec4((0.5 + (amountInLight * 0.5)) * vcolor, 1.0);
        }
    |]


lightVertexShader : Shader Vertex LightUniforms {}
lightVertexShader =
    [glsl|
        attribute vec3 position;
        uniform mat4 perspective;
        uniform mat4 camera;
        void main (void) {
          gl_Position = perspective * camera * vec4(position, 1.0);
        }
     |]


lightFragmentShader : Shader a b {}
lightFragmentShader =
    [glsl|
        precision mediump float;
        vec4 encodeFloat (float depth) {
          const vec4 bitShift = vec4(
            256 * 256 * 256,
            256 * 256,
            256,
            1.0
          );
          const vec4 bitMask = vec4(
            0,
            1.0 / 256.0,
            1.0 / 256.0,
            1.0 / 256.0
          );
          vec4 comp = fract(depth * bitShift);
          comp -= comp.xxyz * bitMask;
          return comp;
        }
        void main (void) {
          gl_FragColor = encodeFloat(gl_FragCoord.z);
        }
    |]
