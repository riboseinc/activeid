fab_names = %i[
  article
  uuid_article
  uuid_article_with_namespace
  uuid_article_with_natural_key
]

fab_names.each do |fab_name|
  Fabricator(fab_name) do
    title { Forgery::LoremIpsum.word }
    body { Forgery::LoremIpsum.sentence }
  end
end
