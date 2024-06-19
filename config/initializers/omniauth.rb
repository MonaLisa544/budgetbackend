Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, '687743905974-tni329gvlecqhtsp95lb15hd06qpl9r0.apps.googleusercontent.com', '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', {
      skip_jwt: true, # This may be necessary depending on your setup
      prompt: 'consent',
      #provider_ignores_state: true
    }
  end