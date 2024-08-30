exports.Platform = class TFBackend {
    postSynth(config) {
      config.provider.aws = [
        {
          "profile": "interviews"
        }
      ];
      return config;
    }
  }