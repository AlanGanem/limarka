# coding: utf-8

module Limarka
  class Trabalho
    # Todas as chaves de configuração devem ser string (e não utilizar simbolos!)
    attr_accessor :configuracao
    attr_accessor :texto, :anexos, :apendices, :errata
    attr_reader :referencias
    
    def initialize(configuracao: {}, texto: nil, anexos: nil, apendices: nil, referencias_bib: nil, errata: nil)
      self.configuracao = configuracao
      self.texto = texto
      self.anexos = anexos
      self.apendices = apendices
      self.referencias_bib = referencias_bib
      self.errata = errata
    end

#    def configuracao=(c)
#      # http://stackoverflow.com/questions/800122/best-way-to-convert-strings-to-symbols-in-hash
#      @configuracao = c.inject({}){|h,(k,v)| h[k.to_s] = v; h} # convert to strings
#    end

    def anexos=(a)
      @anexos = a
      if (a) then
        @configuracao.merge!('anexos' => true)
      else
        @configuracao.merge!('anexos' => false)
      end
    end

    def anexos?
      @configuracao['anexos']
    end

    def errata?
      @configuracao['errata']
    end

    def errata=(e)
      @errata = e
      if (e) then
        @configuracao.merge!('errata' => true)
      else
        @configuracao.merge!('errata' => false)
      end
    end

    
    def apendices=(a)
      @apendices = a
      if (a) then
        @configuracao.merge!('apendices' => true)
      else
        @configuracao.merge!('apendices' => false)
      end
    end

    def apendices?
      @configuracao['apendices']
    end

    def anexos?
      @configuracao['anexos']
    end
    
    def referencias_bib?
      @referencias
    end
    
    def referencias_bib=(ref)
      @referencias = ref
    end
    
    def self.default_texto_file
      "trabalho-academico.md"
    end
    def self.default_errata_file
      "errata.md"
    end
    def self.default_anexos_file
      "anexos.md"
    end
    def self.default_apendices_file
      "apendices.md"
    end

    def self.default_referencias_bib_file
      "referencias.bib"
    end

    def self.default_configuracao_file
      'configuracao.yaml'
    end

    def atualiza_de_arquivos(options)
      self.configuracao = ler_configuracao(options)
      # transforma os simbolos em string: http://stackoverflow.com/questions/8379596/how-do-i-convert-a-ruby-hash-so-that-all-of-its-keys-are-symbols?noredirect=1&lq=1
      # @configuracao.inject({}){|h,(k,v)| h[k.intern] = v; h} 
      self.texto = ler_texto
      self.referencias_bib = ler_referencias(self.configuracao)
      self.apendices = ler_apendices if apendices?
      self.anexos = ler_anexos if anexos?
    end

    def ler_configuracao(options)
      if options and options[:configuracao_yaml] then
        File.open('configuracao.yaml', 'r') {|f| YAML.load(f.read)}
      else
        ler_configuracao_pdf 'configuracao.pdf'
      end
    end

    def ler_configuracao_pdf(file)
      raise IOError, 'Arquivo não encontrado: ' + file unless File.exist? (file)
      pdf = PdfForms::Pdf.new file, (PdfForms.new 'pdftk'), utf8_fields: true
      pdfconf = Limarka::Pdfconf.new(pdf: pdf)
      pdfconf.exporta
    end

    def ler_apendices
      File.open('apendices.md', 'r') {|f| f.read} if apendices?
    end

    def ler_anexos
      File.open('anexos.md', 'r') {|f| f.read} if anexos?
    end
    
    def ler_texto
      File.open('trabalho-academico.md', 'r') {|f| f.read}
    end
    
    def ler_referencias(configuracao)
      File.open(configuracao['referencias_caminho'], 'r') {|f| f.read}
    end
    
    def save(dir)
      Dir.chdir(dir) do
        File.open(Trabalho.default_texto_file, 'w'){|f| f.write texto} if texto
        File.open(configuracao['referencias_caminho'], 'w'){|f| f.write referencias} if referencias_bib?
        File.open(Trabalho.default_anexos_file, 'w'){|f| f.write anexos} if anexos?
        File.open(Trabalho.default_apendices_file, 'w'){|f| f.write apendices} if apendices?
        File.open(Trabalho.default_errata_file, 'w'){|f| f.write errata} if errata?
        File.open(Trabalho.default_configuracao_file, 'w') do |f|
          f.write YAML.dump(configuracao)
          f.write "\n---\n"
        end
      end
    end
  end
end