models: let
  minimal = {
    inherit
      (models)
      DreamShaper_8_pruned
      juggernautXL_version6Rundiffusion
      zavy-chroma-xl
      realisticVisionV51_v51VAE
      fooocus_inpaint_head
      inpaint_v26-fooocus
      MAT_Places512_G_fp16
      clip_vision-sd15
      control_lora_rank128_v11f1e_sd15_tile_fp16
      control_v11p_sd15_inpaint_fp16
      ip-adapter_sd15
      ip-adapter_sdxl_vit-h
      hyper-sd15
      hyper-sdxl
      OmniSR_X2_DIV2K
      OmniSR_X3_DIV2K
      OmniSR_X4_DIV2K
      "4x_NMKD-Superscale-SP_178000_G"
      ;
  };

  optional = {
    inherit
      (models)
      mistoline
      depth_anything_v2_vitb
      sai_xl_canny_256lora
      xinsir-openpose-xl
      sdxl_segmentation_controlnet_ade20k
      control_lora_rank128_v11p_sd15_scribble # control_v11p_sd15_scribble
      control-lora-sketch-rank
      control_lora_rank128_v11p_sd15_lineart # control_v11p_sd15_lineart
      control_lora_rank128_v11p_sd15_softedge # control_v11p_sd15_softedge
      control_lora_rank128_v11p_sd15_canny # control_v11p_sd15_canny
      control-lora-canny-rank
      control_lora_rank128_v11f1p_sd15_depth # control_v11f1p_sd15_depth # control_sd15_depth_anything
      control-lora-depth-rank
      control_lora_rank128_v11p_sd15_normalbae # control_v11p_sd15_normalbae
      control_lora_rank128_v11p_sd15_openpose # control_v11p_sd15_openpose
      control-lora-openposexl2-rank # thibaud_xl_openpose
      control_lora_rank128_v11p_sd15_seg # control_v11p_sd15_seg
      ttplanet_sdxl_controlnet_tile_realistic # ttplanetsdxlcontrolnet
      control_sd15_inpaint_depth_hand
      control_v1p_sd15_qrcode_monster
      control_v1p_sdxl_qrcode_monster
      ip-adapter-faceid-plusv2_sd15 # ip-adapter-faceid-plus_sd15
      ip-adapter-faceid-plusv2_sdxl # ip-adapter-faceid_sdxl;
      ip-adapter-faceid-plusv2_sd15_lora # ip-adapter-faceid-plus_sd15_lora
      ip-adapter-faceid-plusv2_sdxl_lora # ip-adapter-faceid_sdxl_lora
      ;
  };
in {
  inherit minimal optional;
  full = minimal // optional;
}
