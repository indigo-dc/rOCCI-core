# encoding: UTF-8

module Occi
  module Parser
    describe Text do

      context '.category' do
        let(:yamled){ YAMLHash.new }
        let(:expected){ YAMLHash.new }

        it 'parses a string describing an OCCI Category' do
          category_string = 'Category: a_a1-_;scheme="http://a.a/a#";class="kind";title="aA1!\"§$%&/()=?`´ß+*#-_.:,;<>";rel="http://a.a/b#a";location="/a1-A/";attributes="a_1-_.a1-_a a-1.a.b";actions="http://a.a/a1#a1 http://a.b1/b1#b2"'
          category = Occi::Parser::Text.category category_string
          yamled.load(YAML::dump(category))
          expected.load_file("spec/occi/parser/text_samples/occi_category.yml")
          expect(yamled).to eql expected
        end

        it 'parses a string describing an OCCI Category with unquoted class value' do
          category_string = 'Category: a_a1-_;scheme="http://a.a/a#";class=kind'
          category = Occi::Parser::Text.category category_string
          yamled.load(YAML::dump(category))
          expected.load_file("spec/occi/parser/text_samples/occi_category_unquoted.yml")
          expect(yamled).to eql expected
        end

        it 'parses a string describing an OCCI Category with uppercase term' do
          category_string = 'Category: TERM;scheme="http://a.a/a#";class=kind'
          category = Occi::Parser::Text.category category_string
          yamled.load(YAML::dump(category))
          expected.load_file("spec/occi/parser/text_samples/occi_category_uppercase.yml")
          expect(yamled).to eql expected
        end

        it 'parses a string describing an OCCI Category incl. attributes with properties' do
          category_string = 'Category: restart;scheme="http://schemas.ogf.org/occi/infrastructure/compute/action#";class="action";title="Restart Compute instance";attributes="method{required} test{immutable}"'
          category = Occi::Parser::Text.category category_string

          expect(category.attributes['method'].required).to be true
          expect(category.attributes['method'].mutable).to be true
          expect(category.attributes['test'].required).to be false
          expect(category.attributes['test'].mutable).to be false
        end

        it 'parses attributes correctly' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_resource_w_attributes.text", "rt").read
          collection = Occi::Parser::Text.category resource_string
          yamled.load(YAML::dump(collection))
          expected.load_file("spec/occi/parser/text_samples/occi_resource_w_attributes.yml")
          expect(yamled).to eql expected
        end

        it 'parses inline links correctly' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_resource_w_inline_links_only.text", "rb").read
          collection = Occi::Parser::Text.category resource_string
          yamled.load(YAML::dump(collection))
          expected.load_file("spec/occi/parser/text_samples/occi_resource_w_inline_links_only.yml")
          expect(yamled).to eql expected
        end

        it 'parses inline Links and Mixins correctly' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_resource_w_inline_links.text", "rb").read
          collection = Occi::Parser::Text.category resource_string
          yamled.load(YAML::dump(collection))
          expected.load_file("spec/occi/parser/text_samples/occi_resource_w_inline_links.yml")
          expect(yamled).to eql expected
        end

        it 'parses action correctly' do
          category_string = 'Category: restart;scheme="http://schemas.ogf.org/occi/infrastructure/compute/action#";class="action";title="Restart Compute instance";attributes="method"'
          category = Occi::Parser::Text.category category_string
          yamled.load(YAML::dump(category))
          expected.load_file("spec/occi/parser/text_samples/occi_category_w_action.yml")
          expect(yamled).to eql expected
        end

        it 'parses network resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_network_rocci_server.text", "rt").read
          collection =  Occi::Parser::Text.category resource_string
          yamled.load(YAML::dump(collection))
          expected.load_file("spec/occi/parser/text_samples/occi_network_rocci_server.yml")
          expect(yamled).to eql expected
        end
        
        it 'parses storage resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_storage_rocci_server.text", "rt").read
          collection =  Occi::Parser::Text.category resource_string
          yamled.load(YAML::dump(collection))
          expected.load_file("spec/occi/parser/text_samples/occi_storage_rocci_server.yml")
          expect(yamled).to eql expected
        end
        
        it 'parses compute resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_compute_rocci_server.text", "rt").read
          collection =  Occi::Parser::Text.category resource_string
          yamled.load(YAML::dump(collection))
          expected.load_file("spec/occi/parser/text_samples/occi_compute_rocci_server.yml")
          expect(yamled).to eql expected
        end
        
        it 'parses model from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_model_rocci_server.text", "rb").read
          collection =  Occi::Parser::Text.category resource_string
          yamled.load(YAML::dump(collection))
          expected.load_file("spec/occi/parser/text_samples/occi_model_rocci_server.yml")
          expect(yamled).to eql expected
        end
        
        it 'raises error for obviously nonsensical class' do
          category_string = 'Category: restart;scheme="http://schemas.ogf.org/occi/infrastructure/compute/action#";class="actions";title="Restart Compute instance";attributes="method"'
          expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
        end

        it 'raises error for cleverly nonsensical class' do
          category_string = 'Category: restart;scheme="http://schemas.ogf.org/occi/infrastructure/compute/action#";class="action|mixin";title="Restart Compute instance";attributes="method"'
          expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
        end

        it 'raises error for a nonsensical class even with lenient regexp' do
          category_string = 'Category: restart;scheme="http://schemas.ogf.org/occi/infrastructure/compute/action#";class="invalid";title="Restart Compute instance";attributes="method"'

          regexp_category = Occi::Parser::Text::Constants.const_get('REGEXP_CATEGORY')
          regexp_category_alt = regexp_category
          regexp_category_alt['action'] = 'invalid'

          Occi::Parser::Text::Constants.const_set('REGEXP_CATEGORY', regexp_category_alt)

          expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
          Occi::Parser::Text.const_set('REGEXP_CATEGORY', regexp_category)
        end
      end

      context '.resource' do
        let(:yamled){ YAMLHash.new }
        let(:expected){ YAMLHash.new }

        it 'parses network resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_network_rocci_server.text", "rt").read
          resource = Occi::Parser::Text.resource resource_string
          yamled.load(YAML::dump(resource))
          expected.load_file("spec/occi/parser/text_samples/occi_network_rocci_server.resource.yml")
          expect(yamled).to eql expected
        end

        it 'parses storage resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_storage_rocci_server.text", "rt").read
          resource =  Occi::Parser::Text.resource resource_string
          yamled.load(YAML::dump(resource))
          expected.load_file("spec/occi/parser/text_samples/occi_storage_rocci_server.resource.yml")
          expect(yamled).to eql expected
        end
        
        it 'parses compute resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_compute_rocci_server.text", "rt").read
          resource =  Occi::Parser::Text.resource resource_string
          yamled.load(YAML::dump(resource))
          expected.load_file("spec/occi/parser/text_samples/occi_compute_rocci_server.resource.yml")
          expect(yamled).to eql expected
        end

        it 'types parsed compute resource from rOCCI server as Occi::Infrastructure::Compute' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_compute_rocci_server.text", "rb").read
          expected_class = Occi::Infrastructure::Compute
          resource_class =  Occi::Parser::Text.resource(resource_string).resources.first.class
          expect(resource_class).to eql expected_class
        end
      end

      context '.categories' do
        let(:yamled) { YAMLHash.new }
        let(:expected) { YAMLHash.new }

        it 'parses strings describing OCCI Categories' do
          categories_string = File.open("spec/occi/parser/text_samples/occi_categories.text", "rb").read
          categories = Occi::Parser::Text.categories categories_string
          yamled.load(YAML::dump(categories))
          expected.load_file("spec/occi/parser/text_samples/occi_categories.yml")
          expect(yamled).to eql expected
        end

        it 'parses strings describing OCCI Categories, skipping unparseable additions' do
          categories_string = File.open("spec/occi/parser/text_samples/occi_categories.text", "rb").read
          categories_string["\n"] = "\n\n&*$this won't parse\n"
          categories = Occi::Parser::Text.categories categories_string
          yamled.load(YAML::dump(categories))
          expected.load_file("spec/occi/parser/text_samples/occi_categories.yml")
          expect(yamled).to eql expected
        end

        it 'does not fail on unparseable input' do
          categories_string = "\n\n&*$this won't parse\n"
          categories = Occi::Parser::Text.categories categories_string
          expect(categories.blank?).to eql true
        end

      end

      context '.link' do
        let(:yamled){ YAMLHash.new }
        let(:expected){ YAMLHash.new }

        it 'parses link resource instance' do
          link_string = File.open("spec/occi/parser/text_samples/occi_link_resource_instance.text", "rb").read
          link = Occi::Parser::Text.link link_string
          yamled.load(YAML::dump(link))
          expected.load_file("spec/occi/parser/text_samples/occi_link_resource_instance.yml")
          expect(yamled).to eql expected
        end

      end

      context '.location' do
        it 'parses single location' do
          location_string = "X-OCCI-Location: http://example.com:8090/a/b/vm1"
          location = Occi::Parser::Text.location location_string
          expected = "http://example.com:8090/a/b/vm1"
          expect(location).to eql expected
        end
      end

      context '.locations' do
        let(:locations_string){ "X-OCCI-Location: http://example.com:8090/a/b/vm1\nX-OCCI-Location: http://example.com:8090/a/b/vm2" }
        let(:expected){ ["http://example.com:8090/a/b/vm1", "http://example.com:8090/a/b/vm2"] }

        it 'parses multiple locations' do
          locations = Occi::Parser::Text.locations locations_string
          expect(locations).to eql expected
        end

        it 'parses multiple locations, skipping unparseable additions' do
          locations_string["\n"] = "\n\n&*$this won't parse\n"
          locations = Occi::Parser::Text.locations locations_string
          expect(locations).to eql expected
        end
      end

      context '.attribute' do
      end

      context '.link_string' do
        let(:yamled){ YAMLHash.new }
        let(:expected){ YAMLHash.new }

        it 'parses string with category set' do
          link_string = File.open("spec/occi/parser/text_samples/occi_link_simple.text", "rt").read
          link = Occi::Parser::Text.link_string link_string, nil
          yamled.load(YAML::dump(link))
          expected.load_file("spec/occi/parser/text_samples/occi_link_simple.link_string.yml")
          expect(yamled).to eql expected
        end

        it 'parses link with category' do
          link_string = File.open("spec/occi/parser/text_samples/occi_link_w_category.text", "rt").read
          link = Occi::Parser::Text.link_string link_string, nil
          yamled.load(YAML::dump(link))
          expected.load_file("spec/occi/parser/text_samples/occi_link_w_category.yml")
          expect(yamled).to eql expected
        end

        it 'parses link with attributes' do
          link_string = File.open("spec/occi/parser/text_samples/occi_link_w_attributes.text", "rt").read
          link = Occi::Parser::Text.link_string link_string, nil
          yamled.load(YAML::dump(link))
          expected.load_file("spec/occi/parser/text_samples/occi_link_w_attributes.yml")
          expect(yamled).to eql expected
        end

        it 'parses string with action link' do
          link_string = 'Link: </compute/04106bce-87eb-4f8f-a665-2f624e54ba46?action=restart>; rel="http://schemas.ogf.org/occi/infrastructure/compute/action#restart"'
          link = Occi::Parser::Text.link_string(link_string, "source")
          yamled.load(YAML::dump(link))
          expected.load_file("spec/occi/parser/text_samples/occi_link_w_action_link.yml")
          expect(yamled).to eql expected
        end
      end

      context 'compatibility' do
        after(:each) { Occi::Settings.reload! }
        let(:yamled){ YAMLHash.new }
        let(:expected){ YAMLHash.new }

        context 'terms' do
          it 'parses uppercase term, compatibility on' do
            Occi::Settings['compatibility']=true
            category_string = 'Category: TERM;scheme="http://a.a/a#";class=kind'
            category = Occi::Parser::Text.category category_string
            yamled.load(YAML::dump(category))
            expected.load_file("spec/occi/parser/text_samples/occi_term_w_compatibility.yml")
            expect(yamled).to eql expected
          end

          it 'refuses uppercase term, compatibility off' do
            Occi::Settings['compatibility']=false
            category_string = 'Category: TERM;scheme="http://a.a/a#";class=kind'
            expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
          end

          it 'parses term starting with number, compatibility on' do
            Occi::Settings['compatibility']=true
            category_string = 'Category: 1TERM;scheme="http://a.a/a#";class=kind'
            category = Occi::Parser::Text.category category_string
            yamled.load(YAML::dump(category))
            expected.load_file("spec/occi/parser/text_samples/occi_numeric_term_w_compatibility.yml")
            expect(yamled).to eql expected
          end

          it 'refuses term starting with number, compatibility off' do
            Occi::Settings['compatibility']=false
            category_string = 'Category: 1TERM;scheme="http://a.a/a#";class=kind'
            expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
          end

        end

        context 'schemes' do
          it 'parses a Category, compatibility on' do
            Occi::Settings['compatibility']=true
            category_string = 'Category: a_a1-_;scheme="http://a.a/a#a_a1-_";class="kind";title="aA1!\"§$%&/()=?`´ß+*#-_.:,;<>";rel="http://a.a/b#a";location="/a1-A/";attributes="a_1-_.a1-_a a-1.a.b";actions="http://a.a/a1#a1 http://a.b1/b1#b2"'
            category = Occi::Parser::Text.category category_string
            yamled.load(YAML::dump(category))
            expected.load_file("spec/occi/parser/text_samples/occi_term_by_schemes_w_compatibility.yml")
            expect(yamled).to eql expected
          end

          it 'parses a Category, compatibility off' do
            Occi::Settings['compatibility']=false
            category_string = 'Category: a_a1-_;scheme="http://a.a/a#a_a1-_";class="kind";title="aA1!\"§$%&/()=?`´ß+*#-_.:,;<>";rel="http://a.a/b#a";location="/a1-A/";attributes="a_1-_.a1-_a a-1.a.b";actions="http://a.a/a1#a1 http://a.b1/b1#b2"'
            expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
          end
        end
      end

      context 'other OCCI implementations' do
        it 'renders correctly OCCI from other sources'
      end

    end
  end
end
