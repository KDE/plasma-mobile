project(contour_recommendation)

set(recommendationmanager_SRC
  recommendationaction.cpp
  recommendation.cpp
  recommendationmanager.cpp
)

kde4_add_library(contourrecommendation
  ${recommendationmanager_SRC}
)
