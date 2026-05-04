browser-setup:
  npx agent-browser install

browser url:
  npx agent-browser open {{url}}

# In Node projects that add agent-browser to devDependencies, prefer:
# browser-setup:
#   npm exec -- agent-browser install
#
# browser url:
#   npm exec -- agent-browser open {{url}}
