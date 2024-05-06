models: {
  checkpoints = {
    inherit (models.checkpoints)
      DreamShaper_8_pruned
      juggernautXL_version6Rundiffusion
      realisticVisionV51_v51VAE;
  };
  inpaint = {
    inherit (models.inpaint)
      fooocus_inpaint_head
      "inpaint_v26.fooocus"
      MAT_Places512_G_fp16;
  };
  "clip_vision/sd1.5" = {
    inherit (models."clip_vision/sd1.5")
      model;
  };
  controlnet = {
    inherit (models.controlnet)
      control_lora_rank128_v11f1e_sd15_tile_fp16
      control_v11p_sd15_inpaint_fp16;
  };
  ipadapter = {
    inherit (models.ipadapter)
      ip-adapter_sd15
      ip-adapter_sdxl_vit-h;
  };
  loras = {
    inherit (models.loras)
      lcm-lora-sdv1-5
      lcm-lora-sdxl;
  };
  upscale_models = {
    inherit (models.upscale_models)
      OmniSR_X2_DIV2K
      OmniSR_X3_DIV2K
      OmniSR_X4_DIV2K;
  };
}
