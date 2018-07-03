ActAsGroup.configure do
  # Which ORM should be used. By default it makes use of `Rails.cache`. If you want to personalize
  # the behavior your are free to do it. You only have to declare a module such as
  # ActAsGroup::Orm::Custom with the methods `.find`, `.create` and `#save` and the call orm with
  # the name of the module demodulized
  # orm :custom

  # Logic to authorize the following actions:
  # - Creation, update or destroy of the group document
  # - Operations on the original resources
  authorize? do |resource, action, user|
    class_policy = Pundit::PolicyFinder.new(resource).policy
    class_policy.new(user, resource).send("#{action}?")
  end

  # Updates the resource in the database. By default it makes use of `update` on the document, if
  # you want to personalize which method should be used, it could be make by means of the following:
  # update_resource do |document, attributes|
  #   In this case the behavior has been changed to use set, avoiding calling callbacks
  #   document.set(attributes)
  # end

  # Removes the resource. By default it makes use of `destroy` on the document, if you want to
  # personalize the behavior, this method should be used.
  # destroy_resource do |document|
  #   document.delete
  # end
end
