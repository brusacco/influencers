# frozen_string_literal: true

module InstagramServices
  class GetProfileData < ApplicationService
    def initialize(uid)
      @uid = uid
    end

    def call
      url = 'https://www.instagram.com/graphql/query'
      api_url = "http://api.scrape.do?token=ed138ed418924138923ced2b81e04d53&url=#{CGI.escape(url)}"

      headers = { 'Content-Type': 'application/x-www-form-urlencoded', 'x-ig-app-id': '936619743392459' }

      variables = {
        id: @uid,
        render_surface: 'PROFILE',
        __relay_internal__pv__IGDProjectCannesEnabledGKrelayprovider: false
      }

      params = {
        av: 0,
        __d: 'www',
        __user: 0,
        __a: 1,
        __req: 1,
        __hs: '20311.HYP:instagram_web_pkg.2.1...0',
        dpr: 2,
        __ccg: 'GOOD',
        __rev: '1025736249',
        __s: 'ia7pd3:ojs89c:1yxqcj',
        __hsi: '7537347528232208801',
        __dyn: '7xeUjG1mxu1syUbFp41twpUnwgU7SbzEdF8aUco2qwJw5ux609vCwjE1EE2Cw8G11wBz81s8hwGxu786a3a1YwBgao6C0Mo2swtUd8-U2zxe2GewGw9a361qw8Xxm16wa-0oa2-azo7u3vwDwHg2ZwrUdUbGwmk0zU8oC1Iwqo5p0OwUQp1yUb8jxKi2qi7E5y4UrwHwcObBK4o16UswFwtF8',
        __csr: 'g8Y8OJtblN2aHmRKSKLht9sy_KilpvdO6XJAmuFpmVCheiLyHyOuh4pAjjKF9KlAAh-qjZpFlFfGZ4gyGKKEGVQmaBx68Qay4fVohAgSHyA-pADAummubpK44aixd1aHForyVqCXjyUgKi4oG5oSUlyF4FWG3yeCyVU01oDE7u0iJw5Da0jl02fU4C0Oo1723o3uyu8jScwgE0tLx60K8S0bMwlmeyVUjzJwu81j82Rg2Vye2q0gKpegJCyU198720hW8PwJg2Dl0bi1Lwr8zw15e00yo80A20hm039u',
        __hsdp: 'l6gjga7di16HVyNdpegeMC2O227olxQJ0jUieaPABo62U32ohKQ3LwwxW7i3A-2zXwxwyw8d3jwpoK7Ua8ao30x2QE4u7UkwExi0sui1zw1dq0Bo6C3O1KU4-cw960B83Fwc28wg82JaU1aoek2K7z93UW0jO0z8',
        __hblp: '0Pwloco8UgwCwn8W0ii2y1_wLwhC227kaK4K48vAB-UXzbwywSwaaexmbAAxmbxOXwxwc2maJabG3y69Ekxu2m0Vob8-5o2eAwgUvxa7E1ho1iE1B87W2i2C16zE5G78Gmewk8b84acw960B83Fwc28wg89U4q5bwBaU3nxC3u2V2lU9UqIOhoCeGi1Eg27wgE6m2qcw',
        __comet_req: 7,
        lsd: 'AVqJ6APMwKM',
        jazoest: '2885',
        __spin_r: '1025736249',
        __spin_b: 'trunk',
        __spin_t: '1754925476',
        __crn: 'comet.igweb.PolarisProfileRoute',
        fb_api_caller_class: 'RelayModern',
        fb_api_req_friendly_name: 'PolarisProfilePageContentQuery',
        variables: variables.to_json,
        server_timestamps: true,
        doc_id: '24090101933962533'
      }

      body = URI.encode_www_form(params)

      response = HTTParty.post(api_url, headers:, body:, timeout: 60)

      data = JSON.parse(response.body)
      handle_success(data)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
