class Settore < Ohm::Model
  attribute :nome
  index :nome
end

class Area < Ohm::Model
  attribute :nome
  index :nome
end


class Ateneo < Ohm::Model
  attribute :nome
  index :nome
end


class Dottorato < Ohm::Model
  include Ohm::Callbacks

  attribute :nome
  index :nome

  attribute :ciclo
  index :ciclo

  attribute :ateneo
  index :ateneo

  attribute :dipartimento
  index :dipartimento

  attribute :settori
  index :settore

  attribute :aree
  index :area

  #
  # frammentano la stringa contenente settori/aree rilevanti in una array
  # (consente di cercare dottorati per uno o piu' settori/aree )
  #

  def settore(settori = self.settori)
    settori.to_s.split(/\s?;\s?/).uniq
  end

  def area(area = self.aree)
    aree.to_s.split(/\s?;\s?/).uniq
  end

  def validate
    assert_numeric :ciclo
  end

  protected
  #
  # Non appena salvato il record 'Dottorato'
  # crea un sotto-record per ogni settore/area/ateneo ad esso assegnato.
  #
  def after_save
    %w[settore area ateneo].each do |attr|
      klass = Kernel.const_get(attr.capitalize)
      Array(send(attr)).each { |name| klass.find(:nome => name).any? || klass.create(:nome => name) }
    end
  end

  class << self
    def per_ateneo(ateneo)
      find(:ateneo => ateneo)
    end

    def per_ciclo(ciclo)
      find(:ciclo => "%02d" % ciclo)
    end

    def per_area(area)
      find(:area => area)
    end

    def per_settore(settore)
      find(:settore => settore)
    end

    def distribuzione(attributo)
      group_by(&attributo.to_sym)
    end
  end

end
