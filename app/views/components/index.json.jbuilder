json.array!(@components) do |component|
  json.partial! 'components/component', component: component
end

