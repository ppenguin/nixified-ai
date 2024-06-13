let
  fetchModel = import <nix/fetchurl.nix>;
in {
  checkpoints = {
    realisticVisionV51_v51VAE = (fetchModel {
      name = "realisticVisionV51_v51VAE.safetensors";
      url = "https://huggingface.co/lllyasviel/fav_models/resolve/main/fav/realisticVisionV51_v51VAE.safetensors";
      sha256 = "sha256-FQEsU49QPOLr/CyFR7Jox1zNr/eigdtVOZlA/x1w4h0=";
    });

    DreamShaper_8_pruned = (fetchModel {
      name = "DreamShaper_8_pruned.safetensors";
      url = "https://huggingface.co/Lykon/DreamShaper/resolve/main/DreamShaper_8_pruned.safetensors";
      sha256 = "sha256-h521I8MNO5AXFD1WcFAV4VostWKHYsEdCG/tlTir1/0=";
    });

    juggernautXL_version6Rundiffusion = (fetchModel {
      name = "juggernautXL_version6Rundiffusion.safetensors";
      url = "https://huggingface.co/lllyasviel/fav_models/resolve/main/fav/juggernautXL_version6Rundiffusion.safetensors";
      sha256 = "sha256-H+bH7FTHhgQM2rx7TolyAGnZcJaSLiDQHxPndkQStH8=";
    });

    # A high quality checkpoint but beware it also does nsfw very
    # easily.
    # https://civitai.com/models/147720/colossus-project-xl-sfwandnsfw
    # Some notes on usage, from the description:
    # Be aware that some samplers aren't working. Don't use following samplers:
    # DPM++ 2M Karras, DPM++ 2M,DPM++ 2M, DPM++ 2M SDE, DPM++ 2M SDE Heun,
    # Euler, LMS, LMS Karras, Heun, 3M SDE Karras, DPM fast, DPM2 Karras,
    # Restart, PLMS, DDIM, Uni PC, LCM, LCM Karras.
    # Recommended sampler:
    # In my tests DPM 2 a and DPM++ 2S a worked really good for fine
    # details. You can also use the Karras versions of these samplers. Also
    # DPM++ SDE, DPM++ SDE Karras, Euler a, Euler a Turbo, DDPM, DDPM
    # Karras, DPM++ 2M Turbo, DPM++ 2M SDE Heun Exponential worked great in
    # my tests.
    #
    # Keep the CFG around 2-4.
    colossus-xl-v6 = (fetchModel {
      name = "colossus-xl-v6.safetensors";
      url = "https://civitai.com/api/download/models/355884";
      sha256 = "sha256-ZymMt9jS1Z698wujJGxEMQZeyt0E97qaOtLfDdWjhuc=";
    });

    # https://civitai.com/models/112902/dreamshaper-xl
    # Preferred settings:
    # CFG = 2
    # 4-8 sampling steps.
    # Sampler: DPM SDE Kerras (not 2M).
    # ComfyUI workflow for upscaling: https://pastebin.com/79XN01xs
    dreamshaper-xl-fp16 = (fetchModel {
      name = "dreamshaper-xl-fp16.safetensors";
      url = "https://civitai.com/api/download/models/351306";
      sha256 = "sha256-RJazbUi/18/k5dvONIXbVnvO+ivvcjjSkNvUVhISUIM=";
    });

    # Pony generates some really high quality images - they tend to be more
    # based on a digital painting style but can do other things as well.
    # This makes it an excellent model for generating characters.
    # WARNING:  Pony is capable of generating some _very_ NSFW
    # images.  You should be able to use the negative prompt "nsfw" and
    # perhaps others to avoid this.
    pony-xl-v6 = (fetchModel {
      name = "pony-xl-v6.safetensors";
      url = "https://civitai.com/api/download/models/290640?type=Model&format=SafeTensor&size=pruned&fp=fp16";
      sha256 = "1cxh5450k3y9mkrf9dby7hbaydj3ymjwq5fvzsrqk6j3xkc2zav7";
    });

    # Allow for video from images.  See
    # https://comfyanonymous.github.io/ComfyUI_examples/video/ for the
    # official ComfyUI documentation.
    stable-video-diffusion-img2vid-xt = (fetchModel {
      name = "stable-video-diffusion-img2vid-xt.safetensors";
      url = "https://huggingface.co/stabilityai/stable-video-diffusion-img2vid-xt/resolve/main/svd_xt.safetensors?download=true";
      sha256 = "b2652c23d64a1da5f14d55011b9b6dce55f2e72e395719f1cd1f8a079b00a451";
    });

  };

  inpaint = {
    MAT_Places512_G_fp16 = (fetchModel {
      name = "MAT_Places512_G_fp16.safetensors";
      url = "https://huggingface.co/Acly/MAT/resolve/main/MAT_Places512_G_fp16.safetensors";
      sha256 = "sha256-MJ3Wzm4EA03EtrFce9KkhE0VjgPrKhOeDsprNm5AwN4=";
    });

    fooocus_inpaint_head = (fetchModel {
      name = "fooocus_inpaint_head.pth";
      url = "https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/fooocus_inpaint_head.pth";
      sha256 = "sha256-Mvf4OODG2PE0N7qEEed6RojXei4034hX5O9NUfa5dpI=";
    });

    "inpaint_v26.fooocus" = (fetchModel {
      name = "inpaint_v26.fooocus.patch";
      url = "https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/inpaint_v26.fooocus.patch";
      sha256 = "sha256-+GV6AlEE4i1w+cBgY12OjCGW9DOHGi9o3ECr0hcfDVk=";
    });

  };

  clip = {};

  clip_vision = {
    CLIP-ViT-H-14-laion2B-s32B-b79K = (fetchModel {
      name = "CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors";
      sha256 = "sha256-bKlmfaHKngsPdeRrsDD34BH0T4bL+41aNlkPzXUHsDA=";
    });

    CLIP-ViT-bigG-14-laion2B-39B-b160k = (fetchModel {
      name = "CLIP-ViT-bigG-14-laion2B-39B-b160k.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/image_encoder/model.safetensors";
      sha256 = "sha256-ZXcj4J9Gp8OVffZRYBAp9msXSK+xK0GYFjMPFu1F1k0=";
    });

  };

  # this is a bit ugly, but it works when you need to put something in a subdirectory
  "clip_vision/sd1.5" = {
    model = (fetchModel {
      name = "model.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors?download=true";
      sha256 = "sha256-bKlmfaHKngsPdeRrsDD34BH0T4bL+41aNlkPzXUHsDA=";
    });

  };

  configs = {
    # https://huggingface.co/lllyasviel/ControlNet-v1-1
    # https://github.com/lllyasviel/ControlNet-v1-1-nightly
    # See also the accompanying file in `controlnet`.
    controlnet-v1_1_fe-sd15-tile = (fetchModel {
      name = "controlnet-v1_1_fe-sd15-tile.yaml";
      url = "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1e_sd15_tile.yaml";
      sha256 = "sha256-OeEzjEFDYYrbF2BPlsOj90DBq10VV9cbBE8DB6CmrbQ=";
    });

  };

  controlnet = {
    ## SD 1.5

    # https://huggingface.co/lllyasviel/ControlNet-v1-1
    # See also the accompanying file in `configs`.
    controlnet-v1_1_f1e-sd15-tile = (fetchModel {
      name = "controlnet-v1_1_f1e-sd15-tile.pth";
      url = "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1e_sd15_tile.pth";
      sha256 = "sha256-iqabjTkecsL87WplAmgTfcDtWUyv6KLA+LmUeZohl5s=";
    });

    control_v11p_sd15_inpaint_fp16 = (fetchModel {
      name = "control_v11p_sd15_inpaint_fp16.safetensors";
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_inpaint_fp16.safetensors";
      sha256 = "sha256-Z3pP41Ht7NQM0NfMIQqGhrWdTlUgcxfxIxnvdGp6Wok=";
    });

    control_lora_rank128_v11f1e_sd15_tile_fp16 = (fetchModel {
      name = "control_lora_rank128_v11f1e_sd15_tile_fp16.safetensors";
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11f1e_sd15_tile_fp16.safetensors";
      sha256 = "sha256-zsADaemc/tHOyX4RJM8yIN96meRTVOqh4zUMSF5lFU8=";
    });

    control_lora_rank128_v11p_sd15_scribble = (fetchModel {
      name = "control_lora_rank128_v11p_sd15_scribble.safetensors";
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11p_sd15_scribble_fp16.safetensors";
      sha256 = "sha256-8fAojNbUkNmXap9MNigvPUfLjgLcaAWqRLONRAT+AIo=";
    });

    control_lora_rank128_v11p_sd15_lineart = (fetchModel {
      name = "control_lora_rank128_v11p_sd15_lineart.safetensors";
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11p_sd15_lineart_fp16.safetensors";
      sha256 = "sha256-nTqRttVaMSNIPesJ9xzFWKC9VOXsQUL1GHmE29LgmdE=";
    });

    control_lora_rank128_v11p_sd15_softedge = (fetchModel {
      name = "control_lora_rank128_v11p_sd15_softedge.safetensors";
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11p_sd15_softedge_fp16.safetensors";
      sha256 = "sha256-AQiSrKkewwKOtms0troweabbVNqF7UsI8XLg0Gr5sX0=";
    });

    control_lora_rank128_v11p_sd15_canny = (fetchModel {
      name = "control_lora_rank128_v11p_sd15_canny.safetensors";
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11p_sd15_canny_fp16.safetensors";
      sha256 = "sha256-RQU9NBrDbYVZrTAUOPwIsyBCHngqXsiIirivFrd2PGs=";
    });

    control_lora_rank128_v11f1p_sd15_depth = (fetchModel {
      name = "control_lora_rank128_v11f1p_sd15_depth.safetensors";
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11f1p_sd15_depth_fp16.safetensors";
      sha256 = "sha256-egSAgFlH83eYWowmhLjlLN0mX8sltmBOqUCazgjbPTQ=";
    });

    control_lora_rank128_v11p_sd15_normalbae = (fetchModel {
      name = "control_lora_rank128_v11p_sd15_normalbae.safetensors";
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11p_sd15_normalbae_fp16.safetensors";
      sha256 = "sha256-yoQBCo6DLT0uZxx2ZP80X2RfPvfoNZy8o+KzbYa8/zA=";
    });

    control-lora-openposexl2-rank = (fetchModel {
      name = "control-lora-openposexl2-rank.safetensors";
      url = "https://huggingface.co/thibaud/controlnet-openpose-sdxl-1.0/resolve/main/control-lora-openposeXL2-rank256.safetensors";
      sha256 = "sha256-ivoHkoW/k4Tq+PYyKITLTyS75AXaSQ+R9VQNO/9YXnU=";
    });

    control_lora_rank128_v11p_sd15_openpose = (fetchModel {
      name = "control_lora_rank128_v11p_sd15_openpose.safetensors";
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11p_sd15_openpose_fp16.safetensors";
      sha256 = "sha256-bI7d4knmuW9smwUWokPXXritw4Yk7+FxqcirX7Gmlgg=";
    });

    control_lora_rank128_v11p_sd15_seg = (fetchModel {
      name = "control_lora_rank128_v11p_sd15_seg.safetensors";
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11p_sd15_seg_fp16.safetensors";
      sha256 = "sha256-EZN5QVl6ZxUO8PdKow8IKxY0QxCA3uYJ0CMamlm3+k8=";
    });

    control_v1p_sd15_qrcode_monster = (fetchModel {
      name = "control_v1p_sd15_qrcode_monster.safetensors";
      url = "https://huggingface.co/monster-labs/control_v1p_sd15_qrcode_monster/resolve/main/control_v1p_sd15_qrcode_monster.safetensors";
      sha256 = "sha256-x/Q/cOJmFT0S9eG7HJ574/RRPPDu8EMmYbEzG/4Ryt8=";
    });

    control_sd15_inpaint_depth_hand = (fetchModel {
      name = "control_sd15_inpaint_depth_hand.safetensors";
      url = "https://huggingface.co/hr16/ControlNet-HandRefiner-pruned/resolve/main/control_sd15_inpaint_depth_hand_fp16.safetensors";
      sha256 = "sha256-lEt0uO03ARF//lVQAmu/8shhbxySsbsv7gDlNJ/0YlY=";
    });

    ## SD XL

    control-lora-sketch-rank = (fetchModel {
      name = "control-lora-sketch-rank.safetensors";
      url = "https://huggingface.co/stabilityai/control-lora/resolve/main/control-LoRAs-rank128/control-lora-sketch-rank128-metadata.safetensors";
      sha256 = "sha256-Z5xhaAeuxzxHu3KBokp23f5S+ltdaFMvVCq4EzR7Lq4=";
    });

    control-lora-recolor-rank = (fetchModel {
      name = "control-lora-recolor-rank.safetensors";
      url = "https://huggingface.co/stabilityai/control-lora/resolve/main/control-LoRAs-rank128/control-lora-recolor-rank128.safetensors";
      sha256 = "sha256-1sAdWIVQ1Bq0f/JTSuE1RB7Y5hS3KzFnh+i3kWzgjmE=";
    });

    control-lora-canny-rank = (fetchModel {
      name = "control-lora-canny-rank.safetensors";
      url = "https://huggingface.co/stabilityai/control-lora/resolve/main/control-LoRAs-rank128/control-lora-canny-rank128.safetensors";
      sha256 = "sha256-VjiduyRcpE3pHWYlKb1CmKvFXOIxj2C8GUVPty/2gkc=";
    });

    control-lora-depth-rank = (fetchModel {
      name = "control-lora-depth-rank.safetensors";
      url = "https://huggingface.co/stabilityai/control-lora/resolve/main/control-LoRAs-rank128/control-lora-depth-rank128.safetensors";
      sha256 = "sha256-N+ORdX5sAEL6o3lRdKy+EaMZkiUgWM+4u6zPEQc1Z7Q=";
    });

    # https://huggingface.co/TTPlanet/TTPLanet_SDXL_Controlnet_Tile_Realistic_V1
    ttplanet_sdxl_controlnet_tile_realistic = (fetchModel {
      name = "ttplanet_sdxl_controlnet_tile_realistic.safetensors";
      url = "https://huggingface.co/TTPlanet/TTPLanet_SDXL_Controlnet_Tile_Realistic_V1/resolve/main/TTPLANET_Controlnet_Tile_realistic_v1_fp16.safetensors?download=true";
      sha256 = "sha256-+ipfL+yBSBnINUA8d4viwkN9FHkxkhMEVp/M7CtFFzw=";
    });

  };
  ipadapter = {
    # Basic model, average strength
    ip-adapter_sd15 = (fetchModel {
      name = "ip-adapter_sd15.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter_sd15.safetensors";
      sha256 = "sha256-KJtF8W0EPQv1QuRYMflx3Nqr4YtlbxHobZ37p+nuM2k=";
    });

    # SDXL model
    ip-adapter_sdxl_vit-h = (fetchModel {
      name = "ip-adapter_sdxl_vit-h.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter_sdxl_vit-h.safetensors";
      sha256 = "sha256-6/BdkYNIrsersCpens73fgquppFKXE6hP1DUXrFoGDE=";
    });

    # Light impact model
    ip-adapter_sd15_light_v11 = (fetchModel {
      name = "ip-adapter_sd15_light_v11.bin";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter_sd15_light_v11.bin";
      sha256 = "sha256-NQtjpXhHwWPi6YSwEJD4X/5g6q4g8ysrLJ4czH3dlys=";
    });

    # Plus model, very strong
    ip-adapter-plus_sd15 = (fetchModel {
      name = "ip-adapter-plus_sd15.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-plus_sd15.safetensors";
      sha256 = "sha256-ocJQvkBFXMYaQ9oSAew/HtrqcSFIZftH9Xkn4Gy+SZY=";
    });

    # Face model, portraits
    ip-adapter-plus-face_sd15 = (fetchModel {
      name = "ip-adapter-plus-face_sd15.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-plus-face_sd15.safetensors";
      sha256 = "sha256-HJ7cIa9vc33B1uDnNBkOl2z6z4AtawJLd6o76SL3Vps=";
    });

    # Stronger face model, not necessarily better
    ip-adapter-full-face_sd15 = (fetchModel {
      name = "ip-adapter-full-face_sd15.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-full-face_sd15.safetensors";
      sha256 = "sha256-9KF/tkO/h2I1pFoOh6SdooVb5lhLKMoExiqXq1/xxvM=";
    });

    # Base model, requires bigG clip vision encoder
    ip-adapter_sd15_vit-G = (fetchModel {
      name = "ip-adapter_sd15_vit-G.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter_sd15_vit-G.safetensors";
      sha256 = "sha256-om9zavB7s0GoPf6iNxNTHQV1dg6O2UfGjLMaTGLZyQs=";
    });

    # SDXL plus model
    ip-adapter-plus_sdxl_vit-h = (fetchModel {
      name = "ip-adapter-plus_sdxl_vit-h.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus_sdxl_vit-h.safetensors";
      sha256 = "sha256-P1BiuEAMlLcVlmWyG6XGKs3NdoImJ0PX8q7+3vAOZYE=";
    });

    # SDXL face model
    ip-adapter-plus-face_sdxl_vit-h = (fetchModel {
      name = "ip-adapter-plus-face_sdxl_vit-h.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus-face_sdxl_vit-h.safetensors";
      sha256 = "sha256-Z3rYhgIE99C/uhLSnmwx3tm+798+S70QJRg1fTGiksE=";
    });

    # vit-G SDXL model, requires bigG clip vision encoder
    ip-adapter_sdxl = (fetchModel {
      name = "ip-adapter_sdxl.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter_sdxl.safetensors";
      sha256 = "sha256-uhACUp54NgTF8ybUnwEiAlOS0dIKyNVzs+6z5t6k67Y=";
    });

    ## FaceID models (these require the insightface python package, and most require specific loras)

    # base FaceID model
    ip-adapter-faceid_sd15 = (fetchModel {
      name = "ip-adapter-faceid_sd15.bin";
      url = "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid_sd15.bin";
      sha256 = "sha256-IBNE4i5vVYSc8HynpuU9jDsAEyfGbLlxDWn9XaSKjac=";
    });

    # FaceID plus v2
    ip-adapter-faceid-plusv2_sd15 = (fetchModel {
      name = "ip-adapter-faceid-plusv2_sd15.bin";
      url = "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sd15.bin";
      sha256 = "sha256-JtDYah1g1syBHTuIYheLRh4e62Ueb+K3K6F6qVQR4xM=";
    });

    # text prompt style transfer for portraits
    ip-adapter-faceid-portrait-v11_sd15 = (fetchModel {
      name = "ip-adapter-faceid-portrait-v11_sd15.bin";
      url = "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-portrait-v11_sd15.bin";
      sha256 = "sha256-pIy0+J7RjgLGAA9lqp7+xFLofq7Uobyfz0pGDI0OO8Y=";
    });

    # SDXL base FaceID
    ip-adapter-faceid_sdxl = (fetchModel {
      name = "ip-adapter-faceid_sdxl.bin";
      url = "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid_sdxl.bin";
      sha256 = "sha256-9FX+0k4gfIeOweBGazSpadN7q4V8X6pOjSWaC0/2PX4=";
    });

    # SDXL plus v2
    ip-adapter-faceid-plusv2_sdxl = (fetchModel {
      name = "ip-adapter-faceid-plusv2_sdxl.bin";
      url = "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sdxl.bin";
      sha256 = "sha256-xpRdgrVDcAzDzLuY02O4N+nFligWB4V8dLcTqHba9fs=";
    });

    # SDXL text prompt style transfer
    ip-adapter-faceid-portrait_sdxl = (fetchModel {
      name = "ip-adapter-faceid-portrait_sdxl.bin";
      url = "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-portrait_sdxl.bin";
      sha256 = "sha256-VjHOeCTNr9LbN8XoW5hXMKlf9ZxbT8gMK3mwvuVxFRI=";
    });

    # very strong style transfer SDXL only
    ip-adapter-faceid-portrait_sdxl_unnorm = (fetchModel {
      name = "ip-adapter-faceid-portrait_sdxl_unnorm.bin";
      url = "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-portrait_sdxl_unnorm.bin";
      sha256 = "sha256-Igu4biBTk6PQQRYxy0c8rdvzX9NxvikFypAIgYFw21U=";
    });

  };
  embeddings = {};
  loras = {
    lcm-lora-sdv1-5 = (fetchModel {
      name = "lcm-lora-sdv1-5.safetensors";
      url = "https://huggingface.co/latent-consistency/lcm-lora-sdv1-5/resolve/main/pytorch_lora_weights.safetensors?download=true";
      sha256 = "sha256-j5DYQOB1/1iKWOIsZYbirppveSKZbuZkmn8BByMzr+Q=";
    });

    lcm-lora-sdxl = (fetchModel {
      name = "lcm-lora-sdxl.safetensors";
      url = "https://huggingface.co/latent-consistency/lcm-lora-sdxl/resolve/main/pytorch_lora_weights.safetensors?download=true";
      sha256 = "sha256-p2TmhZtuBAR812HAj/DO6WQTqOAEyfB3B1MM13axkUE=";
    });

    # Helps with eyes.
    # https://civitai.com/models/118427/perfect-eyes-xl?modelVersionId=128461
    perfect-eyes-xl = (fetchModel {
      name = "perfect-eyes-xl.safetensors";
      url = "https://civitai.com/api/download/models/128461?type=Model&format=SafeTensor";
      sha256 = "sha256-8kg2TPCsx6ALxLUUW0TA378Q5x6bDvtrd/CVauryQRw=";
    });

    # Helps with indicating various styles in PonyXL, such as oil,
    # realistic, digital art, and combinations thereof.
    # https://civitai.com/models/264290?modelVersionId=398292
    ponyx-xl-v6-non-artist-styles = (fetchModel {
      name = "ponyx-xl-v6-non-artist-styles.safetensors";
      url = "https://civitai.com/api/download/models/398292?type=Model&format=SafeTensor";
      sha256 = "01m4zq2i1hyzvx95nq2v3n18b2m98iz0ryizdkyc1y42f1rwd0kx";
    });

    # TODO: Maybe figure out how to obfuscate?
    ralph-breaks-internet-disney-princesses = (fetchModel {
      name = "ralph-breaks-internet-disney-princesses.safetensors";
      url = "https://civitai.com/api/download/models/244808?type=Model&format=SafeTensor.SafeTensor";
      sha256 = "sha256-gKpnkTrryJoBvhkH5iEi8zn9/ucMFxq3upZ8Xl/PJ+o=";
    });

    ip-adapter-faceid_sd15_lora = (fetchModel {
      name = "ip-adapter-faceid_sd15_lora.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid_sd15_lora.safetensors";
      sha256 = "sha256-cGmfDb+t1H3h+B0mPPTIa9S3Jx2EEwSvmzQLOn846Go=";
    });

    ip-adapter-faceid-plusv2_sd15_lora = (fetchModel {
      name = "ip-adapter-faceid-plusv2_sd15_lora.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sd15_lora.safetensors";
      sha256 = "sha256-ir/4ehWgSfPgGGwugsHI53eDuvLPtj80xBJlYFLrV7A=";
    });

    # SDXL FaceID LoRA
    ip-adapter-faceid_sdxl_lora = (fetchModel {
      name = "ip-adapter-faceid_sdxl_lora.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid_sdxl_lora.safetensors";
      sha256 = "sha256-T8+T1ujcjdGPX55RyDBvNpSG7QqgeAremWEwiv9/DWQ=";
    });

    # SDXL plus v2 LoRA
    ip-adapter-faceid-plusv2_sdxl_lora = (fetchModel {
      name = "ip-adapter-faceid-plusv2_sdxl_lora.safetensors";
      url = "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sdxl_lora.safetensors";
      sha256 = "sha256-8ktLstrWY4oJwA8VHN6EmRuvN0QJOFvLq1PBhxowy3s=";
    });

    # https://civitai.com/models/199663/indigenous-mix-by-noerman
    # SD 1.5
    indigenous-mix-by-noerman = (fetchModel {
      name = "indigenous-mix-by-noerman.safetensors";
      url = "https://civitai.com/api/download/models/227236?type=Model&format=SafeTensor";
      sha256 = "sha256-9OmsnpnknlfMhnWNwRD+RlYOAyYChF7+OgGCU6GGafY=";
    });

    # https://civitai.com/models/201636/south-america-indigenous-mix-by-noerman
    # SD 1.5
    south-america-indigenous-mix-by-noerman = (fetchModel {
      name = "south-america-indigenous-mix-by-noerman.safetensors";
      url = "https://civitai.com/api/download/models/226955?type=Model&format=SafeTensor";
      sha256 = "sha256-HMmTe9ALD+b35BB80lYfM2UMlJsrlYbIVKCLLJ3sJzc=";
    });

  };
  # Upscaler comparisons can be found here:
  # https://civitai.com/articles/636/sd-upscalers-comparison
  upscale_models = {
    "4x_NMKD-Superscale-SP_178000_G" = (fetchModel {
      name = "4x_NMKD-Superscale-SP_178000_G.pth";
      url = "https://huggingface.co/gemasai/4x_NMKD-Superscale-SP_178000_G/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth";
      sha256 = "sha256-HRsAeP5xRG4EadjU31npa6qA2DzaYA1oI31lWDCCG8w=";
    });

    OmniSR_X2_DIV2K = (fetchModel {
      name = "OmniSR_X2_DIV2K.safetensors";
      url = "https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X2_DIV2K.safetensors";
      sha256 = "sha256-eUCPwjIDvxYfqpV8SmAsxAUh7SI1py2Xa9nTdeZkRhE=";
    });

    OmniSR_X3_DIV2K = (fetchModel {
      name = "OmniSR_X3_DIV2K.safetensors";
      url = "https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X3_DIV2K.safetensors";
      sha256 = "sha256-T7C2j8MU95jS3c8fPSJTBFuj2VnYua4nDFqZufhi7hI=";
    });

    OmniSR_X4_DIV2K = (fetchModel {
      name = "OmniSR_X4_DIV2K.safetensors";
      url = "https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X4_DIV2K.safetensors";
      sha256 = "sha256-3/JeTtOSy1y+U02SDikgY6BVXfkoHFTF7DIUkKKlmDI=";
    });

    # https://openmodeldb.info/models/4x-realesrgan-x4plus
    # https://github.com/xinntao/Real-ESRGAN
    real-esrgan-4xplus = (fetchModel {
      name = "real-esrgan-4xplus.pth";
      url = "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth";
      sha256 = "sha256-T6DTiQX3WsButJp5UbQmZwAhvjAYJl/RkdISXfnWgvE=";
    });

    # Doesn't work at all - unsupported model.  Must be older SD version
    # only.
    stable-diffusion-4x-upscaler = (fetchModel {
      name = "stable-diffusion-4x-upscaler.safetensors";
      url = "https://huggingface.co/stabilityai/stable-diffusion-x4-upscaler/resolve/main/x4-upscaler-ema.safetensors?download=true";
      sha256 = "35c01d6160bdfe6644b0aee52ac2667da2f40a33a5d1ef12bbd011d059057bc6";
    });

    # Samael1976 reposted this to civitai.com - the alternative is to
    # download it from mega.nz, which I do not believe is friendly to
    # headless activity such as this.  The original model is listed here:
    # https://openmodeldb.info/models/4x-UltraSharp
    kim2091-4k-ultrasharp = (fetchModel {
      name = "kim2091-4k-ultrasharp.pth";
      url = "https://huggingface.co/Kim2091/UltraSharp/resolve/main/4x-UltraSharp.pth";
      sha256 = "sha256-pYEiMfyTa0KvCKXtunhBlUldMD1bMkjCRInvDEAh/gE=";
    });

  };
  vae = {
    sdxl_vae = (fetchModel {
      name = "sdxl_vae.safetensors";
      url = "https://civitai.com/api/download/models/290640?type=VAE";
      sha256 = "1qf65fia7g0ammwjw2vw1yhijw5kd2c54ksv3d64mgw6inplamr3";
    });

  };
  vae_approx = {};

  insightface = {
    inswapper_128 = (fetchModel {
      name = "inswapper_128.onnx";
      url = "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/inswapper_128.onnx";
      sha256 = "sha256-5KPwjHU8ty0E4Qqg99vj3uu/OVZ9Tq1tzgjpiqSeFq8=";
    });

  };

  facerestore_models = {
    "GFPGANv1.3" = (fetchModel {
      name = "GFPGANv1.3.pth";
      url = "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/facerestore_models/GFPGANv1.3.pth";
      sha256 = "sha256-yVOojycnyFw9mucuK9SEa7r1n+aXKtlBMOI+cBdSSnA=";
    });
    "GFPGANv1.4" = (fetchModel {
      name = "GFPGANv1.4.pth";
      url = "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/facerestore_models/GFPGANv1.4.pth";
      sha256 = "sha256-4s1HA6sU9NAf0Tg6iosmb5pYM9rO6OannTvyGhtr5a0=";
    });
    "codeformer-v0.1.0" = (fetchModel {
      name = "codeformer-v0.1.0.pth";
      url = "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/facerestore_models/codeformer-v0.1.0.pth";
      sha256 = "sha256-EAnlN+DCoH1Mq85jVfU8tmdnzUtCl+x6SmTKS4pWhLc=";
    });
    GPEN-BFR-512 = (fetchModel {
      name = "GPEN-BFR-512.onnx";
      url = "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/facerestore_models/GPEN-BFR-512.onnx";
      sha256 = "sha256-v4CsuOkbqIUuPwElBb4sO2zWs+7V7GBePbh4Y8TnTU4=";
    });

  };

}


