require './grab'

describe Grabber do

  let(:grabber) { Grabber.new(['www.example.com', 'tmp']) }

  describe '#http' do
    accepted_urls = %w(http://example.com https://example.com http://www.example.com https://www.example.com)
    good_urls = %w(www.example.com example.com http://example.com https://example.com http://www.example.com https://www.example.com)
    bad_urls = %w(http http:// https:// http://www com)

    it 'return full domain name' do
      good_urls.each do |url|
        expect(accepted_urls).to include(grabber.http(url))
      end
    end

    it 'return error' do
      bad_urls.each do |url|
        expect(grabber.http(url)).to eq(nil)
      end
    end
  end

  describe '#create_folder' do
    path = 'tmp_test_folder'

    it 'create folder if not exist' do
      expect(grabber.create_folder(path)).to eq(path)
      FileUtils.remove_dir(path)
    end
  end

  describe '#page_source' do
    it 'return page source' do
      expect(grabber.page_source.search('div h1').text).to match("Example Domain")
    end
  end

  describe '#image_url_cleaner' do
    accepted_img_urls = %w(http://example.com/image.png http://www.example.com/image.png example.com/image.png www.example.com/image.png)
    img_urls = %w(//example.com/image.png /image.png http://example.com/image.png example.com/image.png www.example.com/image.png)


    it 'return full images path' do
      img_urls.each do |url|
        expect(accepted_img_urls).to include(grabber.image_url_cleaner(url))
      end
    end
  end

end
