module DataTransform
  module Common
    def skip_defendant(original)
      original.def_name.nil?       ||
      original.first_name.nil?     ||
      original.first_name == "FNU" ||
      original.last_name.nil?      ||
      original.last_name == "LNU"  ||
      original.def_name.match?(/UNKNOWN/)
    end

    def find_or_create_defendant(original)
      candidate = ::Defendant.find_or_create_by!(
        first_name: original.first_name,
        last_name: original.last_name,
      )
      assert_same_attr(:juvenile, candidate, original)
      assert_same_attr(:title, candidate, original)
      candidate.assign_attributes(
        middle_name: original.middle_in,
        title: original.title,
        juvenile: original.juvenile,
        alias: original.alias,
        alias_no: original.alias_no,
      )
      candidate.save!
      candidate
    end

    def find_or_create_organization(original, defendant)
      return unless original.affiliation.present?
      organization = ::Organization.find_or_create_by!(
        name: canonical_org_name(original.affiliation),
        defendant_affiliation_name: original.affiliation
      )
      organization.defendants << defendant
    end


    OrgName = ActiveSheet.use('db/migrate/support/organizations.csv')

    def canonical_org_name(original_name)
      new_name = OrgName.find_by("Original" => original_name).fetch("Reassigned") { nil }
      if new_name
        Rails.logger.info "Using canonical name #{new_name} instead of #{original_name}"
        new_name
      else
        original_name
      end
    end

    def assert_same_attr(attribute, candidate, incoming)
      existing_attr = candidate.send(attribute)
      incoming_attr = incoming.send(attribute)
      if existing_attr.present? && existing_attr != incoming_attr
        return unless incoming_attr.present?
        # TODO: Handle juvenile
        warn <<~MESSAGE
          CONFLICT
          I'm trying to assign #{attribute}=#{incoming_attr} to a record
          that already has #{attribute}=#{existing_attr}.

          Incoming:
            #{incoming.inspect}
          Candidate:
            #{candidate.inspect}
        MESSAGE
      end
    end

  end
end
