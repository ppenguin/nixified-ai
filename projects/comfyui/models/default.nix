{ lib
, fetchurl
}:

let
  fetchModel = import ./fetch-model.nix { inherit lib fetchurl; };
in {
  checkpoints = {
    realisticVisionV51_v51VAE = (fetchModel {
      format = "safetensors";
      url = "https://huggingface.co/lllyasviel/fav_models/resolve/main/fav/realisticVisionV51_v51VAE.safetensors";
      sha256 = "sha256-FQEsU49QPOLr/CyFR7Jox1zNr/eigdtVOZlA/x1w4h0=";
    });

    DreamShaper_8_pruned = (fetchModel {
      format = "safetensors";
      url = "https://huggingface.co/Lykon/DreamShaper/resolve/main/DreamShaper_8_pruned.safetensors";
      sha256 = "sha256-h521I8MNO5AXFD1WcFAV4VostWKHYsEdCG/tlTir1/0=";
    });

    juggernautXL_version6Rundiffusion = (fetchModel {
      format = "safetensors";
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
      url = "https://civitai.com/api/download/models/355884";
      format = "safetensors";
      sha256 = "sha256-ZymMt9jS1Z698wujJGxEMQZeyt0E97qaOtLfDdWjhuc=";
    });

    # https://civitai.com/models/112902/dreamshaper-xl
    # Preferred settings:
    # CFG = 2
    # 4-8 sampling steps.
    # Sampler: DPM SDE Kerras (not 2M).
    # ComfyUI workflow for upscaling: https://pastebin.com/79XN01xs
    dreamshaper-xl-fp16 = (fetchModel {
      url = "https://civitai.com/api/download/models/351306";
      format = "safetensors";
      sha256 = "sha256-RJazbUi/18/k5dvONIXbVnvO+ivvcjjSkNvUVhISUIM=";
    });

    # Pony generates some really high quality images - they tend to be more
    # based on a digital painting style but can do other things as well.
    # This makes it an excellent model for generating characters.
    # WARNING:  Pony is capable of generating some _very_ NSFW
    # images.  You should be able to use the negative prompt "nsfw" and
    # perhaps others to avoid this.
    pony-xl-v6 = (fetchModel {
      # It's critical that the extension is present, or comfyui won't find
      # the file.
      format = "safetensors";
      url = "https://civitai.com/api/download/models/290640?type=Model&format=SafeTensor&size=pruned&fp=fp16";
      sha256 = "1cxh5450k3y9mkrf9dby7hbaydj3ymjwq5fvzsrqk6j3xkc2zav7";
    });

    # Allow for video from images.  See
    # https://comfyanonymous.github.io/ComfyUI_examples/video/ for the
    # official ComfyUI documentation.
    stable-video-diffusion-img2vid-xt = (fetchModel {
      url = "https://huggingface.co/stabilityai/stable-video-diffusion-img2vid-xt/resolve/main/svd_xt.safetensors?download=true";
      format = "safetensors";
      sha256 = "b2652c23d64a1da5f14d55011b9b6dce55f2e72e395719f1cd1f8a079b00a451";
    });

  };
  inpaint = {
    MAT_Places512_G_fp16 = (fetchModel {
      format = "safetensors";
      url = "https://huggingface.co/Acly/MAT/resolve/main/MAT_Places512_G_fp16.safetensors";
      sha256 = "sha256-MJ3Wzm4EA03EtrFce9KkhE0VjgPrKhOeDsprNm5AwN4=";
    });

    fooocus_inpaint_head = (fetchModel {
      format = "pth";
      url = "https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/fooocus_inpaint_head.pth";
      sha256 = "sha256-Mvf4OODG2PE0N7qEEed6RojXei4034hX5O9NUfa5dpI=";
    });

    "inpaint_v26.fooocus" = (fetchModel {
      format = "patch";
      url = "https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/inpaint_v26.fooocus.patch";
      sha256 = "sha256-+GV6AlEE4i1w+cBgY12OjCGW9DOHGi9o3ECr0hcfDVk=";
    });

  };
  clip = {};
  # this is a bit ugly, but it works when you need to put something in a subdirectory
  "clip_vision/sd1.5" = {
    model = (fetchModel {
      format = "safetensors";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors?download=true";
      sha256 = "sha256-bKlmfaHKngsPdeRrsDD34BH0T4bL+41aNlkPzXUHsDA=";
    });

  };
  configs = {
    # https://huggingface.co/lllyasviel/ControlNet-v1-1
    # https://github.com/lllyasviel/ControlNet-v1-1-nightly
    # See also the accompanying file in `controlnet`.
    controlnet-v1_1_fe-sd15-tile = (fetchModel {
      format = "yaml";
      url = "https://huggingface.co/lllyasviel/ControlNet-v1-1/raw/main/control_v11f1e_sd15_tile.yaml";
      sha256 = "sha256-OeEzjEFDYYrbF2BPlsOj90DBq10VV9cbBE8DB6CmrbQ=";
    });
  };
  controlnet = {
    control_v11p_sd15_inpaint_fp16 = (fetchModel {
      format = "safetensors";
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_inpaint_fp16.safetensors";
      sha256 = "sha256-Z3pP41Ht7NQM0NfMIQqGhrWdTlUgcxfxIxnvdGp6Wok=";
    });

    control_lora_rank128_v11f1e_sd15_tile_fp16 = (fetchModel {
      format = "safetensors";
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11f1e_sd15_tile_fp16.safetensors";
      sha256 = "sha256-zsADaemc/tHOyX4RJM8yIN96meRTVOqh4zUMSF5lFU8=";
    });

    # https://huggingface.co/TTPlanet/TTPLanet_SDXL_Controlnet_Tile_Realistic_V1
    ttplanet-sdxl-controlnet-tile-realistic-32-v1 = (fetchModel {
      format = "safetensors";
      url = "https://huggingface.co/TTPlanet/TTPLanet_SDXL_Controlnet_Tile_Realistic_V1/resolve/main/TTPLANET_Controlnet_Tile_realistic_v1_fp32.safetensors?download=true";
      sha256 = "sha256-8zASy6xYOYhfFDqirMsuQDQUx9rRGTZLvhjeN+SmX2c=";
    });

    ttplanet-sdxl-controlnet-tile-realistic-16-v1 = (fetchModel {
      format = "safetensors";
      url = "https://huggingface.co/TTPlanet/TTPLanet_SDXL_Controlnet_Tile_Realistic_V1/resolve/main/TTPLANET_Controlnet_Tile_realistic_v1_fp16.safetensors?download=true";
      sha256 = "sha256-+ipfL+yBSBnINUA8d4viwkN9FHkxkhMEVp/M7CtFFzw=";
    });

    # https://huggingface.co/lllyasviel/ControlNet-v1-1
    # See also the accompanying file in `configs`.
    controlnet-v1_1_f1e-sd15-tile = (fetchModel {
      format = "pth";
      url = "https://huggingface.co/lllyasviel/ControlNet-v1-1/blob/main/control_v11f1e_sd15_tile.pth";
      sha256 = "sha256-GGzAgoSZv+llnOU13H+Zpk7nr1KbTfGbVbJ0u0F2Oho=";
    });

  };
  ipadapter = {
    ip-adapter_sd15 = (fetchModel {
      format = "safetensors";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter_sd15.safetensors";
      sha256 = "sha256-KJtF8W0EPQv1QuRYMflx3Nqr4YtlbxHobZ37p+nuM2k=";
    });
    ip-adapter_sdxl_vit-h = (fetchModel {
      format = "safetensors";
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter_sdxl_vit-h.safetensors";
      sha256 = "sha256-6/BdkYNIrsersCpens73fgquppFKXE6hP1DUXrFoGDE=";
    });
  };
  embeddings = {};
  loras = {
    lcm-lora-sdv1-5 = (fetchModel {
      format = "safetensors";
      url = "https://huggingface.co/latent-consistency/lcm-lora-sdv1-5/resolve/main/pytorch_lora_weights.safetensors?download=true";
      sha256 = "sha256-j5DYQOB1/1iKWOIsZYbirppveSKZbuZkmn8BByMzr+Q=";
    });

    lcm-lora-sdxl = (fetchModel {
      format = "safetensors";
      url = "https://huggingface.co/latent-consistency/lcm-lora-sdxl/resolve/main/pytorch_lora_weights.safetensors?download=true";
      sha256 = "sha256-p2TmhZtuBAR812HAj/DO6WQTqOAEyfB3B1MM13axkUE=";
    });

    # Helps with eyes.
    # https://civitai.com/models/118427/perfect-eyes-xl?modelVersionId=128461
    perfect-eyes-xl = (fetchModel {
      format = "safetensors";
      url = "https://civitai.com/api/download/models/128461?type=Model&format=SafeTensor";
      sha256 = "sha256-8kg2TPCsx6ALxLUUW0TA378Q5x6bDvtrd/CVauryQRw=";
    });

    # Helps with indicating various styles in PonyXL, such as oil,
    # realistic, digital art, and combinations thereof.
    # https://civitai.com/models/264290?modelVersionId=398292
    ponyx-xl-v6-non-artist-styles = (fetchModel {
      format = "safetensors";
      url = "https://civitai.com/api/download/models/398292?type=Model&format=SafeTensor";
      sha256 = "01m4zq2i1hyzvx95nq2v3n18b2m98iz0ryizdkyc1y42f1rwd0kx";
    });

    # TODO: Maybe figure out how to obfuscate?
    ralph-breaks-internet-disney-princesses = (fetchModel {
      url = "https://civitai.com/api/download/models/244808?type=Model&format=SafeTensor";
      format = "safetensors";
      sha256 = "sha256-gKpnkTrryJoBvhkH5iEi8zn9/ucMFxq3upZ8Xl/PJ+o=";
    });

  };
  # Upscaler comparisons can be found here:
  # https://civitai.com/articles/636/sd-upscalers-comparison
  upscale_models = {
    "4x_NMKD-Superscale-SP_178000_G" = (fetchModel {
      url = "https://huggingface.co/gemasai/4x_NMKD-Superscale-SP_178000_G/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth";
      format = "pth";
      sha256 = "sha256-HRsAeP5xRG4EadjU31npa6qA2DzaYA1oI31lWDCCG8w=";
    });

    OmniSR_X2_DIV2K = (fetchModel {
      url = "https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X2_DIV2K.safetensors";
      format = "safetensors";
      sha256 = "sha256-eUCPwjIDvxYfqpV8SmAsxAUh7SI1py2Xa9nTdeZkRhE=";
    });

    OmniSR_X3_DIV2K = (fetchModel {
      url = "https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X3_DIV2K.safetensors";
      format = "safetensors";
      sha256 = "sha256-T7C2j8MU95jS3c8fPSJTBFuj2VnYua4nDFqZufhi7hI=";
    });

    OmniSR_X4_DIV2K = (fetchModel {
      url = "https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X4_DIV2K.safetensors";
      format = "safetensors";
      sha256 = "sha256-3/JeTtOSy1y+U02SDikgY6BVXfkoHFTF7DIUkKKlmDI=";
    });

    # https://openmodeldb.info/models/4x-realesrgan-x4plus
    # https://github.com/xinntao/Real-ESRGAN
    real-esrgan-4xplus = (fetchModel {
      url = "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth";
      format = "pth";
      sha256 = "sha256-T6DTiQX3WsButJp5UbQmZwAhvjAYJl/RkdISXfnWgvE=";
    });

    # Doesn't work at all - unsupported model.  Must be older SD version
    # only.
    stable-diffusion-4x-upscaler = (fetchModel {
      url = "https://huggingface.co/stabilityai/stable-diffusion-x4-upscaler/resolve/main/x4-upscaler-ema.safetensors?download=true";
      format = "safetensors";
      sha256 = "35c01d6160bdfe6644b0aee52ac2667da2f40a33a5d1ef12bbd011d059057bc6";
    });

    # Samael1976 reposted this to civitai.com - the alternative is to
    # download it from mega.nz, which I do not believe is friendly to
    # headless activity such as this.  The original model is listed here:
    # https://openmodeldb.info/models/4x-UltraSharp
    kim2091-4k-ultrasharp = (fetchModel {
      format = "pth";
      url = "https://huggingface.co/Kim2091/UltraSharp/blob/main/4x-UltraSharp.pth";
      # sha256 = "sha256-pYEiMfyTa0KvCKXtunhBlUldMD1bMkjCRInvDEAh/gE=";
      # sha256 = "sha256-JZDtqx4ZEUbexkONl9z2BV8viMFmRnalj6NfoDeYNgU=";
      sha256 = "sha256-/bsIyNqkATcNTyj4rVQzEwQYphVXgUBVXVQo9eroJj0=";
      # SHA256 reported by civitai.com.  Unsure how these relate.  It is not
      # base64 encoded.
      # "A5812231FC936B42AF08A5EDBA784195495D303D5B3248C24489EF0C4021FE01"
    });

  };
  vae = {
    sdxl_vae = (fetchModel {
      format = "safetensors";
      url = "https://civitai.com/api/download/models/290640?type=VAE";
      sha256 = "1qf65fia7g0ammwjw2vw1yhijw5kd2c54ksv3d64mgw6inplamr3";
    });

  };
  vae_approx = {};
}


